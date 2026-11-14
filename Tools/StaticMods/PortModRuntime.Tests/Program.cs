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
    private static readonly List<string> Events = new List<string>();
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
            using (var first = StaticModHooks.Register("first", Target, Callback(nameof(High), 800)))
            using (var last = StaticModHooks.Register("last", Target, Callback(nameof(Low), 0)))
            {
                Equal(true, StaticModHooks.HasForeignHooks(Target, "first"), "Foreign owner detected");
                Game(1);
                Equal("high,low,original", string.Join(",", Events), "Priority ordering");
                StaticModHooks.RemoveOwner("first");
                Events.Clear(); Game(1);
                Equal("low,original", string.Join(",", Events), "Removal does not affect another owner");
                first.Dispose(); first.Dispose();
            }
            Throws<NotSupportedException>(() => StaticModHooks.Register("a", typeof(Program).GetMethod(nameof(Unwrapped)), Callback(nameof(High))), "Unwrapped targets rejected");
            Throws<NotSupportedException>(() => StaticModHooks.Register("a", Target, Callback(nameof(BadParameter))), "Unsupported argument rejected");
            Throws<ArgumentException>(() => StaticModHooks.Register("a", Target, Callback(nameof(BadType))), "Argument type mismatch rejected");
            var owner = new StaticHookOwner("atomic");
            Throws<ArgumentException>(() => owner.Patch(Target, new HookMethod(Callback(nameof(High)).Method), new HookMethod(Callback(nameof(BadType)).Method)), "Partial registration rolls back");
            Equal(false, StaticModHooks.HasHooks(Target), "Rollback left no callbacks");
            Throws<NotSupportedException>(() => owner.Patch(Target, transpiler: new HookMethod(Callback(nameof(High)).Method)), "Transpilers rejected");
            Console.WriteLine("PASS: " + count + " static callback assertions (no Unity/game execution).");
            return 0;
        }
        catch (Exception error) { Console.Error.WriteLine(error); return 1; }
    }

    private static HookCallback Callback(string name, int priority = 400) => new HookCallback(typeof(Program).GetMethod(name, BindingFlags.NonPublic | BindingFlags.Static), priority);
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
    private static void BadParameter(int __unsupported) { }
    private static void BadType(string value) { }
    private static void Equal<T>(T expected, T actual, string name)
    { count++; if (!EqualityComparer<T>.Default.Equals(expected, actual)) throw new Exception(name + ": expected " + expected + ", got " + actual); }
    private static void Throws<T>(Action action, string name) where T : Exception
    { count++; try { action(); } catch (T) { return; } throw new Exception(name + ": expected " + typeof(T).Name); }
}
