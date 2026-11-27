using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;

[assembly: System.Reflection.AssemblyVersion("2.4.2.0")]
[assembly: InternalsVisibleTo("Assembly-CSharp")]

namespace HarmonyLib
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public sealed class HarmonyPatch : Attribute
    {
        public readonly Type TargetType;
        public readonly string MethodName;
        public readonly Type[] ArgumentTypes;

        public HarmonyPatch() { }

        public HarmonyPatch(Type declaringType, string methodName)
            : this(declaringType, methodName, null)
        {
        }

        public HarmonyPatch(Type declaringType, string methodName, params Type[] argumentTypes)
        {
            TargetType = declaringType;
            MethodName = methodName;
            ArgumentTypes = argumentTypes;
        }
    }

    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public sealed class HarmonyPriority : Attribute
    {
        public readonly int Priority;

        public HarmonyPriority(int priority)
        {
            Priority = priority;
        }
    }

    [AttributeUsage(AttributeTargets.Method)]
    public sealed class HarmonyPrepare : Attribute { }

    [AttributeUsage(AttributeTargets.Method)]
    public sealed class HarmonyPrefix : Attribute { }

    [AttributeUsage(AttributeTargets.Method)]
    public sealed class HarmonyPostfix : Attribute { }

    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public sealed class HarmonyBefore : Attribute
    {
        internal readonly string[] Owners;
        public HarmonyBefore(params string[] owners) { Owners = owners; }
    }

    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public sealed class HarmonyAfter : Attribute
    {
        internal readonly string[] Owners;
        public HarmonyAfter(params string[] owners) { Owners = owners; }
    }

    public sealed class Harmony
    {
        internal static Action<Assembly, string, Assembly> PatchAssembly;
        internal static Action<Assembly, string> RemovePatches;
        internal static Func<Assembly, string, IEnumerable<MethodBase>> QueryPatches;
        private readonly string id;

        public Harmony(string id)
        {
            if (string.IsNullOrWhiteSpace(id)) throw new ArgumentException("A Harmony ID is required.", nameof(id));
            this.id = id;
        }

        [MethodImpl(MethodImplOptions.NoInlining)]
        public void PatchAll(Assembly assembly) => PatchAssembly(Assembly.GetCallingAssembly(), id, assembly);

        [MethodImpl(MethodImplOptions.NoInlining)]
        public void UnpatchAll(string harmonyID = null) => RemovePatches(Assembly.GetCallingAssembly(), harmonyID);

        [MethodImpl(MethodImplOptions.NoInlining)]
        public IEnumerable<MethodBase> GetPatchedMethods() => QueryPatches(Assembly.GetCallingAssembly(), id);
    }

    public static class AccessTools
    {
        private const BindingFlags Declared = BindingFlags.Public | BindingFlags.NonPublic |
            BindingFlags.Instance | BindingFlags.Static | BindingFlags.DeclaredOnly;

        public static FieldInfo Field(Type type, string name)
        {
            if (string.IsNullOrEmpty(name)) return null;
            for (var declaring = type; declaring != null; declaring = declaring.BaseType)
            {
                var field = declaring.GetField(name, Declared);
                if (field != null) return field;
            }
            return null;
        }

        public static MethodInfo Method(Type type, string name, Type[] parameters = null, Type[] generics = null)
        {
            for (var declaring = type; declaring != null; declaring = declaring.BaseType)
            {
                var method = DeclaredMethod(declaring, name, parameters, generics);
                if (method != null) return method;
            }
            return null;
        }

        public static MethodInfo DeclaredMethod(Type type, string name, Type[] parameters = null, Type[] generics = null)
        {
            if (type == null || string.IsNullOrEmpty(name)) return null;
            var methods = type.GetMethods(Declared).Where(method => method.Name == name);
            if (parameters != null)
                methods = methods.Where(method => method.GetParameters().Select(p => p.ParameterType).SequenceEqual(parameters));
            var candidates = methods.ToArray();
            if (candidates.Length == 0) return null;
            if (candidates.Length != 1) throw new AmbiguousMatchException(type.FullName + "." + name);
            return generics == null ? candidates[0] : candidates[0].MakeGenericMethod(generics);
        }

        public static MethodInfo PropertyGetter(Type type, string name) => FindProperty(type, name)?.GetGetMethod(true);
        public static MethodInfo PropertySetter(Type type, string name) => FindProperty(type, name)?.GetSetMethod(true);

        private static PropertyInfo FindProperty(Type type, string name)
        {
            if (string.IsNullOrEmpty(name)) return null;
            for (var declaring = type; declaring != null; declaring = declaring.BaseType)
            {
                var property = declaring.GetProperty(name, Declared);
                if (property != null) return property;
            }
            return null;
        }

        public static ConstructorInfo Constructor(Type type, Type[] parameters = null, bool searchForStatic = false)
        {
            var flags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly | BindingFlags.ExactBinding |
                (searchForStatic ? BindingFlags.Static : BindingFlags.Instance);
            return type?.GetConstructor(flags, null, parameters ?? Type.EmptyTypes, null);
        }
    }
}
