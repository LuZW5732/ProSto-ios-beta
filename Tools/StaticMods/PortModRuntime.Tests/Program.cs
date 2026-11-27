using System;
using System.Collections.Generic;
using System.Reflection;
using System.IO;
using System.Reflection.Metadata;
using System.Reflection.PortableExecutable;
using ProbablyStolen.Port.Mods;

internal static class Program
{
    private static readonly MethodInfo Target = typeof(Program).GetMethod(nameof(Game), BindingFlags.NonPublic | BindingFlags.Static);
    private static readonly MethodInfo ReputationTarget = typeof(Program).GetMethod(nameof(ReputationPop), BindingFlags.NonPublic | BindingFlags.Static);
    private static readonly List<string> Events = new List<string>();
    private static readonly List<string> ReputationCalls = new List<string>();
    private static readonly List<(string, double)> ReputationStates = new List<(string, double)>();
    private static readonly List<(string, double)> ObserverStates = new List<(string, double)>();
    private static readonly Exception ReplacementException = new ApplicationException("finalizer replaced original");
    private static Exception exceptionBeforeReplacement;
    private static Exception exceptionAfterReplacement;
    private static int count;
    private static int Main(string[] args)
    {
        try
        {
            if (args.Length == 1)
            {
                using var stream = File.OpenRead(args[0]);
                using var pe = new PEReader(stream);
                var metadata = pe.GetMetadataReader();
                foreach (var handle in metadata.AssemblyReferences)
                {
                    var name = metadata.GetString(metadata.GetAssemblyReference(handle).Name);
                    if (name.Contains("Harmony") || name.Contains("MonoMod"))
                        throw new Exception("Unexpected iOS assembly dependency: " + name);
                }
                Console.WriteLine("PASS: compiled iOS assembly has no Harmony/MonoMod references (metadata-only inspection).");
            }
            Equal(6, Game(3), "Unregistered original");
            using (StaticModHooks.Register("a", Target, Callback(nameof(Prefix)), Callback(nameof(Postfix)), Callback(nameof(Finalizer))))
            {
                Equal(11, Game(3), "Argument/result changes and shared state");
                Equal("prefix,original,postfix,finalizer:ok", string.Join(",", Events), "Ordering");
                Events.Clear();
            }
            Equal(false, StaticModHooks.HasHooks(Target), "Dispose unregisters");
            using (StaticModHooks.Register("a", Target, Callback(nameof(Cancel)), Callback(nameof(ObserveCancel))))
                Equal(42, Game(2), "Cancellation and postfix");
            using (StaticModHooks.Register("a", Target, finalizer: Callback(nameof(Recover))))
                Equal(77, Game(-1), "Finalizer can suppress exception and set result");
            using (StaticModHooks.Register("a", Target, finalizer: Callback(nameof(Finalizer))))
                Throws<InvalidOperationException>(() => Game(-1), "Original exception retained");
            Events.Clear();
            using (StaticModHooks.Register("a", Target, Callback(nameof(ThrowPrefix)), finalizer: Callback(nameof(Finalizer))))
                Throws<ApplicationException>(() => Game(2), "Callback exception unwrapped");
            Equal("finalizer:error", string.Join(",", Events), "Cleanup after prefix failure");
            Events.Clear();
            using (var last = StaticModHooks.Register("last", Target, Callback(nameof(Low), 0)))
            using (var first = StaticModHooks.Register("first", Target, Callback(nameof(High), 800)))
            {
                Equal(true, StaticModHooks.HasForeignHooks(Target, "first"), "Foreign owner detected");
                Game(1);
                Equal("high,low,original", string.Join(",", Events), "Priority ordering");
                StaticModHooks.RemoveOwner("first");
                Events.Clear(); Game(1);
                Equal("low,original", string.Join(",", Events), "Removal does not affect another owner");
                first.Dispose(); first.Dispose();
            }
            TestRelativeHookOrdering();
            Throws<NotSupportedException>(() => StaticModHooks.Register("a", typeof(Program).GetMethod(nameof(Unwrapped)), Callback(nameof(High))), "Unwrapped targets rejected");
            Throws<NotSupportedException>(() => StaticModHooks.Register("a", Target, Callback(nameof(BadParameter))), "Unsupported argument rejected");
            Throws<ArgumentException>(() => StaticModHooks.Register("a", Target, Callback(nameof(BadType))), "Argument type mismatch rejected");
            var owner = new StaticHookOwner("atomic");
            Throws<ArgumentException>(() => owner.Patch(Target, new HookMethod(Callback(nameof(High)).Method), new HookMethod(Callback(nameof(BadType)).Method)), "Partial registration rolls back");
            Equal(false, StaticModHooks.HasHooks(Target), "Rollback left no callbacks");
            Throws<NotSupportedException>(() => owner.Patch(Target, transpiler: new HookMethod(Callback(nameof(High)).Method)), "Transpilers rejected");
            TestReputationHooks();
            TestPurchaseHooks();
            TestFieldHooks();
            TestExceptionReplacement();
            TestParameterBindings();
            Console.WriteLine("PASS: " + count + " static callback assertions (no Unity/game execution).");
            return 0;
        }
        catch (Exception error) { Console.Error.WriteLine(error); return 1; }
    }

    private class FieldBase
    {
        private int inherited = 3;
        protected int Inherited => inherited;
    }

    private sealed class FieldTarget : FieldBase
    {
        internal static readonly MethodInfo TargetMethod = typeof(FieldTarget).GetMethod(nameof(Call));
        private int value = 7;
        private readonly int constant = 5;

        [StaticHookTarget]
        public int Call()
        {
            return StaticModHooks.Invoke<int>(TargetMethod, this, Array.Empty<object>(),
                _ => value + Inherited + constant);
        }
    }

    private static void TestFieldHooks()
    {
        var instance = new FieldTarget();
        var otherInstance = new FieldTarget();
        Equal(15, instance.Call(), "Initial field values");
        using (StaticModHooks.Register("fields", FieldTarget.TargetMethod,
            Callback(nameof(WriteFields)), Callback(nameof(ReadFields))))
        {
            Equal(34, instance.Call(), "Original and postfix see changes to private fields");
            Equal(34, otherInstance.Call(), "Field bindings resolve to the current instance");
        }
        Equal(22, instance.Call(), "Private field changes persist after the hook is removed");
        Equal(22, otherInstance.Call(), "Calling one instance does not alter the other before its prefix runs");
        Throws<NotSupportedException>(() => StaticModHooks.Register("fields", FieldTarget.TargetMethod,
            Callback(nameof(UnknownField))), "Unknown field rejected");
        Throws<NotSupportedException>(() => StaticModHooks.Register("fields", FieldTarget.TargetMethod,
            Callback(nameof(WriteReadonlyField))), "Readonly ref field rejected");
        Throws<ArgumentException>(() => StaticModHooks.Register("fields", FieldTarget.TargetMethod,
            Callback(nameof(WrongFieldType))), "Field type mismatch rejected");
        Equal(false, StaticModHooks.HasHooks(FieldTarget.TargetMethod), "Invalid field bindings leave no callbacks");
    }

    private static void WriteFields(ref int ___value, ref int ___inherited)
    {
        ___value += 5;
        ___inherited += 2;
    }

    private static void ReadFields(int ___value, int ___constant, ref int __result)
    {
        Equal(5, ___constant, "Readonly field can be read");
        __result += ___value;
    }

    private static void UnknownField(int ___missing) { }
    private static void WriteReadonlyField(ref int ___constant) { }
    private static void WrongFieldType(ref string ___value) { }

    private static void TestExceptionReplacement()
    {
        Events.Clear();
        using var observer = StaticModHooks.Register("exception-observer", Target,
            finalizer: Callback(nameof(ObserveReplacement), 0));
        using var replacement = StaticModHooks.Register("exception-replacement", Target,
            finalizer: Callback(nameof(ReplaceException), 800));
        try
        {
            Game(-1);
        }
        catch (ApplicationException error)
        {
            Equal("original failed", exceptionBeforeReplacement?.Message, "Finalizer receives the original exception");
            Equal(ReplacementException, error, "Caller receives the exception returned by the finalizer");
            Equal(ReplacementException, exceptionAfterReplacement, "Later finalizer receives the replacement exception");
            return;
        }
        throw new Exception("Expected the finalizer to replace the original exception.");
    }

    private static Exception ReplaceException(Exception __exception)
    {
        exceptionBeforeReplacement = __exception;
        return ReplacementException;
    }

    private static void ObserveReplacement(Exception __exception)
    {
        exceptionAfterReplacement = __exception;
    }

    private static void TestParameterBindings()
    {
        using (StaticModHooks.Register("named-argument", Target, Callback(nameof(WriteNamedArgument))))
            Equal(14, Game(3), "Named ref argument is written through to the original delegate");
        using (StaticModHooks.Register("indexed-argument", Target, Callback(nameof(WriteIndexedArgument))))
            Equal(18, Game(3), "Ref __0 is written through to the original argument named value");

        using var state = StaticModHooks.Register("parameters", Target,
            Callback(nameof(CaptureParameterState)), Callback(nameof(ObserveParameterPostfix)),
            Callback(nameof(ObserveParameterFinalizer)));

        Events.Clear();
        Equal(6, Game(3), "Original runs when the prefix returns true");
        Equal("original,parameter-postfix:True:103,parameter-finalizer:103:ok",
            string.Join(",", Events), "Postfix observes __runOriginal and both callbacks receive __state");

        Events.Clear();
        Equal(42, Game(2), "Original is skipped when the prefix returns false");
        Equal("parameter-postfix:False:102,parameter-finalizer:102:ok",
            string.Join(",", Events), "Postfix observes cancellation and both callbacks retain __state");

        Events.Clear();
        Throws<InvalidOperationException>(() => Game(-1), "Void finalizer preserves the original exception");
        Equal("original,parameter-finalizer:99:original failed",
            string.Join(",", Events), "Void finalizer receives __state when the original throws");
    }

    private static void WriteNamedArgument(ref int value) => value += 4;

    private static void WriteIndexedArgument(ref int __0) => __0 += 6;

    private static bool CaptureParameterState(int value, out int __state, ref int __result)
    {
        __state = value + 100;
        if (value != 2)
            return true;
        __result = 42;
        return false;
    }

    private static void ObserveParameterPostfix(bool __runOriginal, int __state)
    {
        Events.Add($"parameter-postfix:{__runOriginal}:{__state}");
    }

    private static void ObserveParameterFinalizer(int __state, Exception __exception)
    {
        Events.Add($"parameter-finalizer:{__state}:{__exception?.Message ?? "ok"}");
    }

    private static void TestPurchaseHooks()
    {
        using var purchase = StaticModHooks.Register("purchase", Target,
            Callback(nameof(PurchasePrefix)), finalizer: Callback(nameof(PurchaseFinalizer)));
        using var observer = StaticModHooks.Register("purchase-observer", Target,
            postfix: Callback(nameof(PurchasePostfix)));

        Events.Clear();
        Equal(7, Game(3), "Purchase postfix updates the original result");
        Equal("purchase-prefix:3,original,purchase-postfix:3:6,purchase-finalizer:3",
            string.Join(",", Events), "Purchase callbacks on normal return");

        Events.Clear();
        Equal(43, Game(2), "Purchase postfix updates the short-circuited result");
        Equal("purchase-prefix:2,purchase-postfix:2:42,purchase-finalizer:2",
            string.Join(",", Events), "Purchase callbacks after cancellation");

        Events.Clear();
        Throws<InvalidOperationException>(() => Game(-1), "Purchase finalizer preserves the original exception");
        Equal("purchase-prefix:-1,original,purchase-finalizer:-1",
            string.Join(",", Events), "Purchase cleanup after failure");

        StaticModHooks.RemoveOwner("purchase");
        Events.Clear();
        Equal(5, Game(2), "Removing the purchase owner restores the original call");
        Equal("original,purchase-postfix:2:4", string.Join(",", Events), "Purchase observer remains registered");
    }

    private static bool PurchasePrefix(object[] __args, ref int __result)
    {
        var value = (int)__args[0];
        Events.Add("purchase-prefix:" + value);
        if (value != 2)
            return true;
        __result = 42;
        return false;
    }

    private static void PurchasePostfix(object[] __args, ref int __result)
    {
        Events.Add("purchase-postfix:" + (int)__args[0] + ":" + __result);
        __result++;
    }

    private static void PurchaseFinalizer(object[] __args) => Events.Add("purchase-finalizer:" + (int)__args[0]);

    private static void TestReputationHooks()
    {
        using var reputation = StaticModHooks.Register("reputation", ReputationTarget,
            Callback(nameof(ReputationPrefix)), Callback(nameof(ReputationPostfix)));
        using var observer = StaticModHooks.Register("observer", ReputationTarget,
            postfix: Callback(nameof(ObserveReputation)));

        ReputationPop("outer");
        ReputationPop("next");
        Equal("outer,inner,next", string.Join(",", ReputationCalls), "Reputation original executes once per invocation");
        Equal(3, ReputationStates.Count, "Reputation postfix runs once per invocation");
        Equal(("inner", 20.5), ReputationStates[0], "Inner invocation receives its prefix state");
        Equal(("outer", 10.25), ReputationStates[1], "Outer invocation retains its prefix state");
        Equal(("next", 30.75), ReputationStates[2], "Sequential invocation receives fresh prefix state");
        Equal(3, ObserverStates.Count, "Second owner runs for each invocation");
        Equal(("inner", 0d), ObserverStates[0], "Inner state is isolated by owner");
        Equal(("outer", 0d), ObserverStates[1], "Outer state is isolated by owner");
        Equal(("next", 0d), ObserverStates[2], "Sequential state is isolated by owner");

        StaticModHooks.RemoveOwner("reputation");
        ReputationPop("removed");
        Equal("outer,inner,next,removed", string.Join(",", ReputationCalls), "Original still executes once after owner removal");
        Equal(3, ReputationStates.Count, "Removed owner receives no further postfix calls");
        Equal(4, ObserverStates.Count, "Removing one owner preserves the other owner");
        Equal(("removed", 0d), ObserverStates[3], "Remaining owner receives default state after removal");
    }

    [StaticHookTarget]
    private static void ReputationPop(string factionId)
    {
        StaticModHooks.Invoke<object>(ReputationTarget, null, new object[] { factionId }, args =>
        {
            var faction = (string)args[0];
            ReputationCalls.Add(faction);
            if (faction == "outer")
                ReputationPop("inner");
            return null;
        });
    }

    private static void ReputationPrefix(string factionId, out double __state)
    {
        __state = factionId switch
        {
            "outer" => 10.25,
            "inner" => 20.5,
            "next" => 30.75,
            _ => throw new InvalidOperationException("Unexpected reputation prefix call for " + factionId)
        };
    }

    private static void ReputationPostfix(string factionId, double __state) => ReputationStates.Add((factionId, __state));
    private static void ObserveReputation(string factionId, double __state) => ObserverStates.Add((factionId, __state));

    private static void TestRelativeHookOrdering()
    {
        using (StaticModHooks.Register("high-runtime", Target, Callback(nameof(High), 800, "high")))
        using (StaticModHooks.Register("after-runtime", Target,
            Callback(nameof(AfterHook), 900, "after", after: new[] { "high", "unknown" })))
        using (StaticModHooks.Register("low-runtime", Target,
            Callback(nameof(Low), 0, "before", before: new[] { "high" })))
        using (StaticModHooks.Register("duplicate-runtime", Target,
            Callback(nameof(DuplicateHook), 100, "before", before: new[] { "high" })))
        {
            ExpectHookOrder("duplicate,low,high,after,original", "Relative dependencies override callback priorities");
            StaticModHooks.RemoveOwner("before");
            ExpectHookOrder("duplicate,low,high,after,original", "Removing an ordering alias leaves registrations intact");
            StaticModHooks.RemoveOwner("low-runtime");
            ExpectHookOrder("duplicate,high,after,original", "Removal preserves other registrations using the same ordering alias");
        }

        using (StaticModHooks.Register("high-runtime", Target,
            Callback(nameof(High), 800, "high", after: new[] { "postfix", "absent" })))
        using (StaticModHooks.Register("low-runtime", Target, Callback(nameof(Low), 400, "low")))
        using (StaticModHooks.Register("postfix-runtime", Target,
            postfix: Callback(nameof(AfterHook), 0, "postfix")))
            ExpectHookOrder("high,low,original,after", "Dependencies on an unknown alias or another stage leave priority intact");

        using (StaticModHooks.Register("low-runtime", Target,
            Callback(nameof(Low), 400, "low", before: new[] { "high" })))
        using (StaticModHooks.Register("high-runtime", Target,
            Callback(nameof(High), 400, "high", before: new[] { "low" })))
        {
            ExpectHookOrder("low,high,original", "Equal-priority conflicts fall back to registration order");
            ExpectHookOrder("low,high,original", "Conflicting callbacks retain the same order on the next invocation");
        }
    }

    private static void ExpectHookOrder(string expected, string assertion)
    {
        Events.Clear();
        Game(1);
        Equal(expected, string.Join(",", Events), assertion);
        Events.Clear();
    }

    private static HookCallback Callback(string name, int priority = 400,
        string ownerId = null, string[] before = null, string[] after = null) =>
        new HookCallback(typeof(Program).GetMethod(name, BindingFlags.NonPublic | BindingFlags.Static),
            priority, ownerId, before, after);
    [StaticHookTarget]
    private static int Game(int value)
    {
        return StaticModHooks.Invoke<int>(Target, null, new object[] { value }, args => {
            Events.Add("original");
            var n = (int)args[0];
            if (n < 0) throw new InvalidOperationException("original failed");
            return n * 2;
        });
    }
    public static int Unwrapped(int value) => value;
    private static void Prefix(ref int value, out int __state) { Events.Clear(); Events.Add("prefix"); __state = value; value++; }
    private static void Postfix(ref int __result, int __state) { Events.Add("postfix"); __result += __state; }
    private static void Finalizer(Exception __exception) { Events.Add("finalizer:" + (__exception == null ? "ok" : "error")); }
    private static bool Cancel(ref int __result) { __result = 42; return false; }
    private static void ObserveCancel(bool __runOriginal) { if (__runOriginal) throw new Exception("Cancellation ignored"); }
    private static Exception Recover(Exception __exception, ref int __result) { __result = 77; return null; }
    private static void ThrowPrefix() => throw new ApplicationException("prefix failed");
    private static void High() { Events.Add("high"); }
    private static void Low() { Events.Add("low"); }
    private static void AfterHook() => Events.Add("after");
    private static void DuplicateHook() => Events.Add("duplicate");
    private static void BadParameter(int __unsupported) { }
    private static void BadType(string value) { }
    private static void Equal<T>(T expected, T actual, string name)
    { count++; if (!EqualityComparer<T>.Default.Equals(expected, actual)) throw new Exception(name + ": expected " + expected + ", got " + actual); }
    private static void Throws<T>(Action action, string name) where T : Exception
    { count++; try { action(); } catch (T) { return; } throw new Exception(name + ": expected " + typeof(T).Name); }
}
