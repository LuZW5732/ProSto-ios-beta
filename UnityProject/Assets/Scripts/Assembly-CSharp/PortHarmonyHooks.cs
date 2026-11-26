#if PROSTO_INTERP
using System;
using System.Linq;
using System.Reflection;
using DseCecil;
using HarmonyLib;
using ProbablyStolen.Port.Mods;

internal static class PortHarmonyHooks
{
    private const string AssemblyName = "0Harmony";
    private const string AttributeName = "HarmonyLib.HarmonyPatch";
    private const string NamedTarget = "System.Void HarmonyLib.HarmonyPatch::.ctor(System.Type,System.String)";
    private const string OverloadedTarget = "System.Void HarmonyLib.HarmonyPatch::.ctor(System.Type,System.String,System.Type[])";
    private const BindingFlags DeclaredMethods = BindingFlags.Public | BindingFlags.NonPublic |
        BindingFlags.Instance | BindingFlags.Static | BindingFlags.DeclaredOnly;

    // Verify the original image before loading it. Accept only the attribute ABI
    // implemented by the interpreter build; executable Harmony APIs need separate adapters.
    internal static void ValidateImage(ModuleDefinition module)
    {
        var references = module.AssemblyReferences.Where(r =>
            string.Equals(r.Name, AssemblyName, StringComparison.OrdinalIgnoreCase)).ToArray();
        if (references.Length == 0) return;
        var shim = typeof(HarmonyPatch).Assembly.GetName();
        if (references.Length != 1 || !string.Equals(references[0].FullName, shim.FullName, StringComparison.Ordinal))
            throw new NotSupportedException("Unsupported Harmony identity: " + string.Join(", ", references.Select(r => r.FullName)));
        foreach (var type in module.GetTypeReferences())
        {
            if (type.Scope?.Name == AssemblyName && type.FullName != AttributeName)
                throw new NotSupportedException("Unsupported Harmony type: " + type.FullName);
        }
        foreach (var member in module.GetMemberReferences())
        {
            if (member.DeclaringType.Scope?.Name == AssemblyName &&
                member.FullName != NamedTarget && member.FullName != OverloadedTarget)
                throw new NotSupportedException("Unsupported Harmony member: " + member.FullName);
        }

        // The first supported grammar is a single class-level target per patch
        // class. Method-level annotations must not silently change its meaning.
        foreach (var type in module.GetTypes())
        {
            foreach (var method in type.Methods)
                if (method.CustomAttributes.Any(a => a.AttributeType.FullName == AttributeName))
                    throw new NotSupportedException("Method-level HarmonyPatch: " + method.FullName);
        }
    }

    internal static void Register(LoadedMod mod)
    {
        if (!mod.Assembly.GetReferencedAssemblies().Any(a => a.Name == AssemblyName)) return;
        int count = 0;
        try
        {
            foreach (var type in mod.Assembly.GetTypes())
            {
                var patches = type.GetCustomAttributes(typeof(HarmonyPatch), false);
                if (patches.Length == 0) continue;
                if (patches.Length != 1)
                    throw new NotSupportedException("Multiple HarmonyPatch targets: " + type.FullName);
                RegisterPatch(mod, type, (HarmonyPatch)patches[0]);
                count++;
            }
            if (count == 0) throw new NotSupportedException("No supported class-level HarmonyPatch in " + mod.Assembly.FullName);
        }
        catch
        {
            Remove(mod);
            throw;
        }
    }

    private static void RegisterPatch(LoadedMod mod, Type patchType, HarmonyPatch patch)
    {
        if (patch.TargetType == null || patch.TargetType.Assembly != typeof(IMod).Assembly ||
            string.IsNullOrEmpty(patch.MethodName))
            throw new NotSupportedException("Expected a named game method on " + patchType.FullName);
        var targets = patch.TargetType.GetMethods(DeclaredMethods).Where(m => m.Name == patch.MethodName &&
            (patch.ArgumentTypes == null || m.GetParameters().Select(p => p.ParameterType).SequenceEqual(patch.ArgumentTypes))).ToArray();
        if (targets.Length != 1)
            throw new NotSupportedException("Missing or ambiguous Harmony target: " + patch.TargetType + "." + patch.MethodName);

        if (patch.TargetType.IsDefined(typeof(ModRestrictedAttribute), false) ||
            targets[0].IsDefined(typeof(ModRestrictedAttribute), false))
            throw new NotSupportedException("Restricted Harmony target: " + patch.TargetType + "." + patch.MethodName);

        var methods = patchType.GetMethods(DeclaredMethods);
        // Never silently omit Harmony conventions such as Prepare or Transpiler.
        foreach (var m in methods)
            if (m.Name == "Prepare" || m.Name == "Cleanup" || m.Name == "TargetMethod" || m.Name == "TargetMethods" ||
                m.Name == "Transpiler" || m.Name == "ILManipulator")
                throw new NotSupportedException("Unsupported Harmony convention: " + patchType.FullName + "." + m.Name);
        var prefix = FindCallback(methods, "Prefix");
        var postfix = FindCallback(methods, "Postfix");
        var finalizer = FindCallback(methods, "Finalizer");
        var before = StateParameter(prefix);
        var after = StateParameter(postfix);
        if ((before != null && (!before.IsOut || !before.ParameterType.IsByRef)) ||
            (after != null && (after.ParameterType.IsByRef || before == null ||
             before.ParameterType.GetElementType() != after.ParameterType)))
            throw new NotSupportedException("Incompatible Harmony __state on " + patchType.FullName);
        StaticModHooks.Register(Owner(mod), targets[0], prefix, postfix, finalizer);
    }

    private static HookCallback FindCallback(MethodInfo[] methods, string name)
    {
        var candidates = methods.Where(m => m.Name == name).ToArray();
        if (candidates.Length == 0) return null;
        if (candidates.Length != 1)
            throw new NotSupportedException("Expected one " + name + " in " + methods[0].DeclaringType);
        var method = candidates[0];
        if (method.ReturnType != typeof(void) &&
            !(name == "Prefix" && method.ReturnType == typeof(bool)))
            throw new NotSupportedException("Unsupported Harmony callback return type: " + method);
        // The dispatcher checks accepted injections against the exact target signature.
        foreach (var p in candidates[0].GetParameters())
            if (p.Name != "__result" &&
                !(p.Name == "__args" && p.ParameterType == typeof(object[])) &&
                !(p.Name == "__state" && name != "Finalizer") &&
                (p.ParameterType.IsByRef || p.Name.StartsWith("__", StringComparison.Ordinal)))
                throw new NotSupportedException("Unsupported Harmony callback parameter: " + candidates[0] + " " + p.Name);
        return new HookCallback(method);
    }

    private static ParameterInfo StateParameter(HookCallback callback) =>
        callback?.Method.GetParameters().SingleOrDefault(p => p.Name == "__state");

    private static string Owner(LoadedMod mod) => "external-harmony:" + mod.Manifest.ID;
    internal static void Remove(LoadedMod mod) => StaticModHooks.RemoveOwner(Owner(mod));
}
#endif
