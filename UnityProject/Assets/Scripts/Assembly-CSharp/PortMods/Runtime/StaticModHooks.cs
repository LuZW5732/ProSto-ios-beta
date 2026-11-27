using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.ExceptionServices;

namespace ProbablyStolen.Port.Mods
{
    // Only methods explicitly wrapped at build time can accept callbacks.
    // This does not patch machine code or implement Harmony's transpiler API.
    [AttributeUsage(AttributeTargets.Method)]
    public sealed class StaticHookTargetAttribute : Attribute { }

    public sealed class HookCallback
    {
        public readonly MethodInfo Method;
        public readonly int Priority;
        internal readonly string OwnerId;
        internal readonly string[] Before;
        internal readonly string[] After;
        public HookCallback(MethodInfo method, int priority = 400,
            string ownerId = null, string[] before = null, string[] after = null)
        {
            Method = method ?? throw new ArgumentNullException(nameof(method));
            Priority = priority;
            OwnerId = ownerId;
            Before = before?.ToArray() ?? Array.Empty<string>();
            After = after?.ToArray() ?? Array.Empty<string>();
            if (!method.IsStatic || method.ContainsGenericParameters)
                throw new NotSupportedException("Callbacks must be closed static methods.");
        }
    }

    public static class StaticModHooks
    {
        private enum Stage { Prefix, Postfix, Finalizer }
        private sealed class Entry
        {
            public long Sequence;
            public string Owner;
            public Stage Stage;
            public HookCallback Callback;
            public FieldInfo[] Fields;
        }
        private static readonly object Gate = new object();
        private static readonly Dictionary<MethodBase, List<Entry>> Entries = new Dictionary<MethodBase, List<Entry>>();
        private static long sequence;

        public static bool HasHooks(MethodBase target)
        {
            lock (Gate) return Entries.TryGetValue(target, out var entries) && entries.Count > 0;
        }

        public static bool HasForeignHooks(MethodBase target, string ownerPrefix)
        {
            lock (Gate) return Entries.TryGetValue(target, out var entries)
                && entries.Any(e => !e.Owner.StartsWith(ownerPrefix, StringComparison.Ordinal));
        }

        public static IDisposable Register(string owner, MethodBase target, HookCallback prefix = null,
            HookCallback postfix = null, HookCallback finalizer = null)
        {
            if (string.IsNullOrWhiteSpace(owner)) throw new ArgumentException("A mod ID is required.", nameof(owner));
            if (target == null) throw new ArgumentNullException(nameof(target));
            if (!target.IsDefined(typeof(StaticHookTargetAttribute), false))
                throw new NotSupportedException("No build-time callback entry: " + target.DeclaringType + "." + target.Name);
            var pending = new List<Entry>();
            Add(Stage.Prefix, prefix); Add(Stage.Postfix, postfix); Add(Stage.Finalizer, finalizer);
            if (pending.Count == 0) throw new ArgumentException("At least one callback is required.");
            lock (Gate)
            {
                if (!Entries.TryGetValue(target, out var entries)) Entries[target] = entries = new List<Entry>();
                foreach (var entry in pending) { entry.Sequence = ++sequence; entries.Add(entry); }
            }
            return new Subscription(target, pending);

            void Add(Stage stage, HookCallback callback)
            {
                if (callback == null) return;
                var fields = Validate(target, callback.Method, stage);
                pending.Add(new Entry { Owner = owner, Stage = stage, Callback = callback, Fields = fields });
            }
        }

        public static void RemoveOwner(string owner)
        {
            lock (Gate)
            {
                foreach (var key in Entries.Keys.ToArray())
                {
                    Entries[key].RemoveAll(e => e.Owner == owner);
                    if (Entries[key].Count == 0) Entries.Remove(key);
                }
            }
        }

        private sealed class Subscription : IDisposable
        {
            private readonly MethodBase target;
            private List<Entry> entries;
            internal Subscription(MethodBase target, List<Entry> entries) { this.target = target; this.entries = entries; }
            public void Dispose()
            {
                lock (Gate)
                {
                    if (entries == null) return;
                    if (Entries.TryGetValue(target, out var current))
                    {
                        foreach (var entry in entries) current.Remove(entry);
                        if (current.Count == 0) Entries.Remove(target);
                    }
                    entries = null;
                }
            }
        }

        private static Type ElementType(Type type) => type.IsByRef ? type.GetElementType() : type;
        private static int ArgumentIndex(MethodBase target, string name)
        {
            var parameters = target.GetParameters();
            if (name.StartsWith("__", StringComparison.Ordinal) && int.TryParse(name.Substring(2), out var index))
                return index >= 0 && index < parameters.Length ? index : -1;
            return Array.FindIndex(parameters, p => p.Name == name);
        }

        private static FieldInfo FindField(Type targetType, string name)
        {
            const BindingFlags flags = BindingFlags.Public | BindingFlags.NonPublic |
                BindingFlags.Instance | BindingFlags.Static | BindingFlags.DeclaredOnly;
            for (var type = targetType; type != null; type = type.BaseType)
            {
                var field = type.GetField(name, flags);
                if (field != null) return field;
            }
            return null;
        }

        private static bool IsModRestricted(MemberInfo member)
        {
            return member.GetCustomAttributesData().Any(attribute =>
                attribute.AttributeType.FullName == "ModRestrictedAttribute");
        }

        private static FieldInfo[] Validate(MethodBase target, MethodInfo callback, Stage stage)
        {
            var returnType = callback.ReturnType;
            if (returnType != typeof(void) && !(stage == Stage.Prefix && returnType == typeof(bool))
                && !(stage == Stage.Finalizer && returnType == typeof(Exception)))
                throw new NotSupportedException("Unsupported callback return type: " + callback);
            var parameters = callback.GetParameters();
            var fields = new FieldInfo[parameters.Length];
            for (int i = 0; i < parameters.Length; i++)
            {
                var parameter = parameters[i];
                var name = parameter.Name;
                var type = ElementType(parameter.ParameterType);
                Type source;
                switch (name)
                {
                    case "__instance":
                        if (target.IsStatic) throw new ArgumentException("Static targets have no instance.");
                        source = target.DeclaringType; break;
                    case "__result": source = (target as MethodInfo)?.ReturnType; break;
                    case "__exception": source = typeof(Exception); break;
                    case "__originalMethod": source = typeof(MethodBase); break;
                    case "__runOriginal": source = typeof(bool); break;
                    case "__args": source = typeof(object[]); break;
                    case "__state": continue;
                    default:
                        if (name.StartsWith("___", StringComparison.Ordinal))
                        {
                            var field = FindField(target.DeclaringType, name.Substring(3));
                            if (field == null)
                                throw new NotSupportedException("Unsupported callback parameter: " + callback + ": " + name);
                            if (IsModRestricted(target.DeclaringType) || IsModRestricted(field.DeclaringType) || IsModRestricted(field))
                                throw new NotSupportedException("Restricted callback field: " + name);
                            if (!field.IsStatic && target.IsStatic)
                                throw new ArgumentException("Static targets have no instance field: " + name);
                            if (parameter.ParameterType.IsByRef &&
                                (field.IsInitOnly || field.IsLiteral || (!field.IsStatic && target.DeclaringType.IsValueType)))
                                throw new NotSupportedException("Read-only callback field: " + name);
                            fields[i] = field;
                            source = field.FieldType;
                            break;
                        }
                        int index = ArgumentIndex(target, name);
                        if (index < 0) throw new NotSupportedException("Unsupported callback parameter: " + callback + ": " + name);
                        source = ElementType(target.GetParameters()[index].ParameterType); break;
                }
                if (source == null || source == typeof(void) || !type.IsAssignableFrom(source)
                    || (parameter.ParameterType.IsByRef && type != source))
                    throw new ArgumentException("Callback parameter type mismatch: " + callback + ": " + name);
                if (parameter.ParameterType.IsByRef && (name == "__instance" || name == "__originalMethod" || name == "__runOriginal" || name == "__args"))
                    throw new NotSupportedException("Read-only callback context: " + name);
            }
            return fields;
        }

        public static T Invoke<T>(MethodBase target, object instance, object[] arguments, Func<object[], T> original)
        {
            Entry[] snapshot;
            lock (Gate)
            {
                if (!Entries.TryGetValue(target, out var entries)) snapshot = Array.Empty<Entry>();
                else snapshot = entries.OrderByDescending(e => e.Callback.Priority).ThenBy(e => e.Sequence).ToArray();
            }
            if (snapshot.Length == 0) return original(arguments);
            if (snapshot.Any(entry => entry.Callback.Before.Length != 0 || entry.Callback.After.Length != 0))
                snapshot = OrderCallbacks(snapshot);
            object result = default(T);
            Exception exception = null;
            bool runOriginal = true;
            var states = new Dictionary<(string, Type), object>();
            try
            {
                foreach (var entry in snapshot.Where(e => e.Stage == Stage.Prefix))
                {
                    // After cancellation, side-effect-free prefixes can still observe the call.
                    if (!runOriginal && (entry.Callback.Method.ReturnType != typeof(void)
                        || entry.Callback.Method.GetParameters().Any(p => p.ParameterType.IsByRef))) continue;
                    if (Call(entry) is bool run && !run) runOriginal = false;
                }
                if (runOriginal) result = original(arguments);
                foreach (var entry in snapshot.Where(e => e.Stage == Stage.Postfix)) Call(entry);
            }
            catch (Exception error) { exception = error; }
            foreach (var entry in snapshot.Where(e => e.Stage == Stage.Finalizer))
            {
                try
                {
                    var value = Call(entry);
                    if (entry.Callback.Method.ReturnType == typeof(Exception)) exception = (Exception)value;
                }
                catch (Exception error) { if (exception == null) exception = error; }
            }
            if (exception != null) ExceptionDispatchInfo.Capture(exception).Throw();
            return (T)result;

            object Call(Entry entry)
            {
                var method = entry.Callback.Method;
                var parameters = method.GetParameters();
                var values = new object[parameters.Length];
                var stateKey = (entry.Owner, method.DeclaringType);
                for (int i = 0; i < values.Length; i++)
                {
                    var field = entry.Fields[i];
                    if (field != null)
                    {
                        values[i] = field.GetValue(field.IsStatic ? null : instance);
                        continue;
                    }
                    var parameter = parameters[i];
                    switch (parameter.Name)
                    {
                        case "__instance": values[i] = instance; break;
                        case "__result": values[i] = result; break;
                        case "__exception": values[i] = exception; break;
                        case "__originalMethod": values[i] = target; break;
                        case "__runOriginal": values[i] = runOriginal; break;
                        case "__args": values[i] = arguments; break;
                        case "__state":
                            if (!states.TryGetValue(stateKey, out values[i]))
                            {
                                var type = ElementType(parameter.ParameterType);
                                values[i] = type.IsValueType ? Activator.CreateInstance(type) : null;
                            }
                            break;
                        default: values[i] = arguments[ArgumentIndex(target, parameter.Name)]; break;
                    }
                }
                object value;
                try { value = method.Invoke(null, values); }
                catch (TargetInvocationException error) when (error.InnerException != null)
                { ExceptionDispatchInfo.Capture(error.InnerException).Throw(); throw; }
                for (int i = 0; i < values.Length; i++)
                {
                    if (!parameters[i].ParameterType.IsByRef) continue;
                    var field = entry.Fields[i];
                    if (field != null)
                    {
                        field.SetValue(field.IsStatic ? null : instance, values[i]);
                        continue;
                    }
                    switch (parameters[i].Name)
                    {
                        case "__result": result = values[i]; break;
                        case "__exception": exception = (Exception)values[i]; break;
                        case "__state": states[stateKey] = values[i]; break;
                        default: arguments[ArgumentIndex(target, parameters[i].Name)] = values[i]; break;
                    }
                }
                return value;
            }
        }

        private static Entry[] OrderCallbacks(Entry[] priorityOrder)
        {
            var result = new List<Entry>(priorityOrder.Length);
            foreach (var stage in new[] { Stage.Prefix, Stage.Postfix, Stage.Finalizer })
            {
                var remaining = priorityOrder.Where(entry => entry.Stage == stage).ToList();
                while (remaining.Count != 0)
                {
                    int next = remaining.FindIndex(entry => !remaining.Any(other => MustRunBefore(other, entry)));
                    // For contradictory constraints, break the cycle by priority and registration order.
                    if (next < 0) next = 0;
                    result.Add(remaining[next]);
                    remaining.RemoveAt(next);
                }
            }
            return result.ToArray();
        }

        private static bool MustRunBefore(Entry first, Entry second)
        {
            if (first == second) return false;
            string firstId = first.Callback.OwnerId ?? first.Owner;
            string secondId = second.Callback.OwnerId ?? second.Owner;
            return firstId != secondId &&
                (first.Callback.Before.Contains(secondId, StringComparer.Ordinal) ||
                 second.Callback.After.Contains(firstId, StringComparer.Ordinal));
        }
    }
}
