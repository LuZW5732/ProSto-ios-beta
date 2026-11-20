using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace ProbablyStolen.Port.Mods
{
    public static class PortReflection
    {
        private const BindingFlags Flags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static | BindingFlags.DeclaredOnly;
        public static FieldInfo Field(Type type, string name)
        {
            for (; type != null; type = type.BaseType)
            { var member = type.GetField(name, Flags); if (member != null) return member; }
            return null;
        }
        public static PropertyInfo Property(Type type, string name)
        {
            for (; type != null; type = type.BaseType)
            { var member = type.GetProperty(name, Flags); if (member != null) return member; }
            return null;
        }
        public static MethodInfo PropertySetter(Type type, string name) => Property(type, name)?.GetSetMethod(true);
        public static MethodInfo Method(Type type, string name, Type[] parameters = null)
        {
            for (; type != null; type = type.BaseType)
            {
                var candidates = type.GetMethods(Flags).Where(m => m.Name == name);
                if (parameters != null) candidates = candidates.Where(m => m.GetParameters().Select(p => p.ParameterType).SequenceEqual(parameters));
                var matches = candidates.ToArray();
                if (matches.Length > 1) throw new AmbiguousMatchException(type + "." + name);
                if (matches.Length == 1) return matches[0];
            }
            return null;
        }
        public static Type TypeByName(string name)
        {
            foreach (var assembly in AppDomain.CurrentDomain.GetAssemblies())
            { var type = assembly.GetType(name, false); if (type != null) return type; }
            return null;
        }
        // Read-only field access; deliberately does not offer emitted ref-return delegates.
        public static Func<T, F> FieldReader<T, F>(string name)
        {
            var field = Field(typeof(T), name) ?? throw new MissingFieldException(typeof(T).FullName, name);
            return value => (F)field.GetValue(value);
        }
    }

    public static class HookPriority
    {
        public const int First = 800, VeryHigh = 700, High = 600, HigherThanNormal = 500,
            Normal = 400, LowerThanNormal = 300, Low = 200, VeryLow = 100, Last = 0;
    }
    // Descriptor for the supported static callback subset, not a Harmony API implementation.
    public sealed class HookMethod
    {
        public readonly MethodInfo method;
        public int priority = HookPriority.Normal;
        public HookMethod(Type type, string name) : this(PortReflection.Method(type, name)) { }
        public HookMethod(MethodInfo method) { this.method = method ?? throw new MissingMethodException(); }
        internal HookCallback Callback => new HookCallback(method, priority);
    }
    public sealed class StaticHookOwner
    {
        private sealed class Owned
        {
            public MethodBase Target;
            public MethodInfo Method;
            public IDisposable Subscription;
        }
        private readonly List<Owned> registrations = new List<Owned>();
        public readonly string Id;
        public StaticHookOwner(string id) { Id = id; }
        public void Patch(MethodBase target, HookMethod prefix = null, HookMethod postfix = null,
            HookMethod transpiler = null, HookMethod finalizer = null)
        {
            if (transpiler != null) throw new NotSupportedException("IL transpilers must be converted into reviewed source edits before building.");
            var added = new List<Owned>();
            try
            {
                Add(prefix, 0); Add(postfix, 1); Add(finalizer, 2);
                registrations.AddRange(added);
            }
            catch { foreach (var entry in added) entry.Subscription.Dispose(); throw; }
            void Add(HookMethod descriptor, int stage)
            {
                if (descriptor == null) return;
                var callback = descriptor.Callback;
                added.Add(new Owned { Target = target, Method = descriptor.method,
                    Subscription = StaticModHooks.Register(Id, target, stage == 0 ? callback : null,
                        stage == 1 ? callback : null, stage == 2 ? callback : null) });
            }
        }
        public void Unpatch(MethodBase target, MethodInfo method)
        {
            foreach (var entry in registrations.Where(e => e.Target.Equals(target) && e.Method.Equals(method)).ToArray())
            { entry.Subscription.Dispose(); registrations.Remove(entry); }
        }
        public void UnpatchAll(string id)
        {
            if (id != Id) throw new ArgumentException("Cannot remove another owner's callbacks.");
            foreach (var entry in registrations) entry.Subscription.Dispose();
            registrations.Clear();
        }
        public static object GetPatchInfo(MethodBase target) => target != null && StaticModHooks.HasHooks(target) ? target : null;
    }
}
