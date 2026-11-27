#if PROSTO_INTERP
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using DseCecil;
using HarmonyLib;
using ProbablyStolen.Port.Mods;

internal static class PortHarmonyHooks
{
    private const string AssemblyName = "0Harmony";
    private const string AttributeName = "HarmonyLib.HarmonyPatch";
    private const string ManualPatchAll = "System.Void HarmonyLib.Harmony::PatchAll(System.Reflection.Assembly)";
    private const BindingFlags DeclaredMethods = BindingFlags.Public | BindingFlags.NonPublic |
        BindingFlags.Instance | BindingFlags.Static | BindingFlags.DeclaredOnly;
    private static readonly HashSet<string> SupportedTypes = new HashSet<string>(StringComparer.Ordinal)
    {
        AttributeName, "HarmonyLib.HarmonyPriority", "HarmonyLib.HarmonyPrepare",
        "HarmonyLib.HarmonyPrefix", "HarmonyLib.HarmonyPostfix", "HarmonyLib.AccessTools",
        "HarmonyLib.Harmony", "HarmonyLib.HarmonyBefore", "HarmonyLib.HarmonyAfter"
    };
    private static readonly HashSet<string> SupportedMembers = new HashSet<string>(StringComparer.Ordinal)
    {
        "System.Void HarmonyLib.HarmonyPatch::.ctor()",
        "System.Void HarmonyLib.HarmonyPatch::.ctor(System.Type,System.String)",
        "System.Void HarmonyLib.HarmonyPatch::.ctor(System.Type,System.String,System.Type[])",
        "System.Void HarmonyLib.HarmonyPriority::.ctor(System.Int32)",
        "System.Void HarmonyLib.HarmonyPrepare::.ctor()",
        "System.Void HarmonyLib.HarmonyPrefix::.ctor()",
        "System.Void HarmonyLib.HarmonyPostfix::.ctor()",
        "System.Void HarmonyLib.HarmonyBefore::.ctor(System.String[])",
        "System.Void HarmonyLib.HarmonyAfter::.ctor(System.String[])",
        "System.Void HarmonyLib.Harmony::.ctor(System.String)",
        ManualPatchAll,
        "System.Void HarmonyLib.Harmony::UnpatchAll(System.String)",
        "System.Collections.Generic.IEnumerable`1<System.Reflection.MethodBase> HarmonyLib.Harmony::GetPatchedMethods()",
        "System.Reflection.MethodInfo HarmonyLib.AccessTools::Method(System.Type,System.String,System.Type[],System.Type[])",
        "System.Reflection.MethodInfo HarmonyLib.AccessTools::DeclaredMethod(System.Type,System.String,System.Type[],System.Type[])",
        "System.Reflection.FieldInfo HarmonyLib.AccessTools::Field(System.Type,System.String)",
        "System.Reflection.MethodInfo HarmonyLib.AccessTools::PropertyGetter(System.Type,System.String)",
        "System.Reflection.MethodInfo HarmonyLib.AccessTools::PropertySetter(System.Type,System.String)",
        "System.Reflection.ConstructorInfo HarmonyLib.AccessTools::Constructor(System.Type,System.Type[],System.Boolean)"
    };

    // Verify the original image before loading it against the ABI implemented by this port.
    internal static bool ValidateImage(ModuleDefinition module)
    {
        var references = module.AssemblyReferences.Where(r =>
            string.Equals(r.Name, AssemblyName, StringComparison.OrdinalIgnoreCase)).ToArray();
        if (references.Length == 0) return false;
        var shim = typeof(HarmonyPatch).Assembly.GetName();
        if (references.Length != 1 || !string.Equals(references[0].FullName, shim.FullName, StringComparison.Ordinal))
            throw new NotSupportedException("Unsupported Harmony identity: " + string.Join(", ", references.Select(r => r.FullName)));
        foreach (var type in module.GetTypeReferences())
        {
            if (type.Scope?.Name == AssemblyName && !SupportedTypes.Contains(type.FullName))
                throw new NotSupportedException("Unsupported Harmony type: " + type.FullName);
        }
        bool manual = false;
        foreach (var member in module.GetMemberReferences())
        {
            if (member.DeclaringType.Scope?.Name != AssemblyName) continue;
            if (!SupportedMembers.Contains(member.FullName))
                throw new NotSupportedException("Unsupported Harmony member: " + member.FullName);
            manual |= member.FullName == ManualPatchAll;
        }

        // The first supported grammar is a single class-level target per patch
        // class. Method-level annotations must not silently change its meaning.
        foreach (var type in module.GetTypes())
        {
            foreach (var method in type.Methods)
                if (method.CustomAttributes.Any(a => a.AttributeType.FullName == AttributeName))
                    throw new NotSupportedException("Method-level HarmonyPatch: " + method.FullName);
        }
        return manual;
    }

    private sealed class PatchScope
    {
        internal readonly Dictionary<string, MethodBase[]> Owners = new Dictionary<string, MethodBase[]>(StringComparer.Ordinal);
        internal string Key(string id) => prefix + id;
        private readonly string prefix;

        internal PatchScope(string modId)
        {
            prefix = "external-harmony:" + modId.Length + ":" + modId + ":";
        }
    }

    private static readonly object Gate = new object();
    private static readonly Dictionary<Assembly, PatchScope> Scopes = new Dictionary<Assembly, PatchScope>();

    static PortHarmonyHooks()
    {
        Harmony.PatchAssembly = PatchFromMod;
        Harmony.RemovePatches = UnpatchFromMod;
        Harmony.QueryPatches = PatchedMethods;
    }

    internal static void Register(LoadedMod mod)
    {
        if (!mod.Assembly.GetReferencedAssemblies().Any(a => a.Name == AssemblyName)) return;
        lock (Gate)
        {
            if (Scopes.ContainsKey(mod.Assembly)) return;
            var scope = new PatchScope(mod.Manifest.ID);
            Scopes.Add(mod.Assembly, scope);
            try
            {
                if (!mod.ManagesHarmonyPatches)
                    PatchAll(scope, mod.Assembly, "mod." + mod.Manifest.ID);
            }
            catch
            {
                Remove(mod);
                throw;
            }
        }
    }

    private static void PatchFromMod(Assembly caller, string id, Assembly targetAssembly)
    {
        if (caller != targetAssembly)
            throw new UnauthorizedAccessException("Harmony can only register patches from the calling mod.");
        lock (Gate) PatchAll(RequireScope(caller), targetAssembly, id);
    }

    private static void UnpatchFromMod(Assembly caller, string id)
    {
        if (string.IsNullOrWhiteSpace(id) || id == "*")
            throw new ArgumentException("Specify a Harmony ID owned by the calling mod.", nameof(id));
        lock (Gate)
        {
            var scope = RequireScope(caller);
            if (scope.Owners.TryGetValue(id, out var targets) && targets == null)
                throw new InvalidOperationException("Cannot unpatch an owner while it is registering: " + id);
            if (scope.Owners.Remove(id)) StaticModHooks.RemoveOwner(scope.Key(id));
        }
    }

    private static IEnumerable<MethodBase> PatchedMethods(Assembly caller, string id)
    {
        lock (Gate)
            return RequireScope(caller).Owners.TryGetValue(id, out var targets) && targets != null
                ? targets.ToArray() : Array.Empty<MethodBase>();
    }

    private static PatchScope RequireScope(Assembly assembly)
    {
        if (assembly != null && Scopes.TryGetValue(assembly, out var scope)) return scope;
        throw new UnauthorizedAccessException("Harmony caller is not an enabled external mod.");
    }

    private static void PatchAll(PatchScope scope, Assembly assembly, string ownerId)
    {
        if (scope.Owners.ContainsKey(ownerId)) return;
        scope.Owners.Add(ownerId, null);
        var targets = new HashSet<MethodBase>();
        int count = 0;
        try
        {
            foreach (var type in assembly.GetTypes())
            {
                var patches = type.GetCustomAttributes(typeof(HarmonyPatch), false);
                if (patches.Length == 0) continue;
                if (patches.Length != 1)
                    throw new NotSupportedException("Multiple HarmonyPatch targets: " + type.FullName);
                RegisterPatch(scope.Key(ownerId), ownerId, type, (HarmonyPatch)patches[0], targets);
                count++;
            }
            if (count == 0) throw new NotSupportedException("No supported class-level HarmonyPatch in " + assembly.FullName);
            scope.Owners[ownerId] = targets.ToArray();
        }
        catch
        {
            StaticModHooks.RemoveOwner(scope.Key(ownerId));
            scope.Owners.Remove(ownerId);
            throw;
        }
    }

    private static void RegisterPatch(string owner, string ownerId, Type patchType, HarmonyPatch patch, HashSet<MethodBase> patched)
    {
        var methods = patchType.GetMethods(DeclaredMethods);
        foreach (var m in methods)
            if (m.Name == "Cleanup" || m.Name == "Transpiler" || m.Name == "ILManipulator")
                throw new NotSupportedException("Unsupported Harmony convention: " + patchType.FullName + "." + m.Name);

        var prepare = FindPatchMethod(methods, "Prepare", typeof(HarmonyPrepare));
        if (prepare != null)
        {
            ValidateFactory(prepare, typeof(bool));
            if (!(bool)prepare.Invoke(null, null)) return;
        }
        var targets = ResolveTargets(patchType, patch, methods);
        int defaultPriority = patchType.GetCustomAttribute<HarmonyPriority>(false)?.Priority ?? 400;
        var beforeOwners = patchType.GetCustomAttribute<HarmonyBefore>(false)?.Owners;
        var afterOwners = patchType.GetCustomAttribute<HarmonyAfter>(false)?.Owners;
        var prefix = FindCallback(FindPatchMethod(methods, "Prefix", typeof(HarmonyPrefix)), "Prefix", defaultPriority, ownerId, beforeOwners, afterOwners);
        var postfix = FindCallback(FindPatchMethod(methods, "Postfix", typeof(HarmonyPostfix)), "Postfix", defaultPriority, ownerId, beforeOwners, afterOwners);
        var finalizer = FindCallback(FindPatchMethod(methods, "Finalizer"), "Finalizer", defaultPriority, ownerId, beforeOwners, afterOwners);
        var before = StateParameter(prefix);
        if ((before != null && (!before.IsOut || !before.ParameterType.IsByRef)) ||
            !CanReadState(StateParameter(postfix), before) ||
            !CanReadState(StateParameter(finalizer), before))
            throw new NotSupportedException("Incompatible Harmony __state on " + patchType.FullName);
        foreach (var target in targets)
        {
            if (target?.DeclaringType?.Assembly != typeof(IMod).Assembly ||
                target.DeclaringType.IsDefined(typeof(ModRestrictedAttribute), false) ||
                target.IsDefined(typeof(ModRestrictedAttribute), false))
                throw new NotSupportedException("Expected an unrestricted game method from " + patchType.FullName + ": " + target);
            StaticModHooks.Register(owner, target, prefix, postfix, finalizer);
            patched.Add(target);
        }
    }

    private static MethodBase[] ResolveTargets(Type patchType, HarmonyPatch patch, MethodInfo[] methods)
    {
        var single = FindPatchMethod(methods, "TargetMethod");
        var multiple = FindPatchMethod(methods, "TargetMethods");
        if (patch.TargetType != null && !string.IsNullOrEmpty(patch.MethodName) && single == null && multiple == null)
        {
            var targets = patch.TargetType.GetMethods(DeclaredMethods).Where(m => m.Name == patch.MethodName &&
                (patch.ArgumentTypes == null || m.GetParameters().Select(p => p.ParameterType).SequenceEqual(patch.ArgumentTypes))).ToArray();
            if (targets.Length == 1) return targets;
            throw new NotSupportedException("Missing or ambiguous Harmony target: " + patch.TargetType + "." + patch.MethodName);
        }
        if (patch.TargetType != null || patch.MethodName != null || (single == null) == (multiple == null))
            throw new NotSupportedException("Expected a named target or one target factory on " + patchType.FullName);
        if (single != null)
        {
            ValidateFactory(single, typeof(MethodBase));
            return new[] { (MethodBase)single.Invoke(null, null) };
        }
        ValidateFactory(multiple, typeof(IEnumerable<MethodBase>));
        var selected = (IEnumerable<MethodBase>)multiple.Invoke(null, null);
        if (selected == null) throw new NotSupportedException("Null Harmony target list from " + multiple);
        return selected.Distinct().ToArray();
    }

    private static void ValidateFactory(MethodInfo method, Type resultType)
    {
        if (!method.IsStatic || method.ContainsGenericParameters || method.GetParameters().Length != 0 ||
            !resultType.IsAssignableFrom(method.ReturnType))
            throw new NotSupportedException("Unsupported Harmony factory signature: " + method);
    }

    private static MethodInfo FindPatchMethod(MethodInfo[] methods, string name, Type marker = null)
    {
        var candidates = methods.Where(m => m.Name == name || (marker != null && m.IsDefined(marker, false))).ToArray();
        if (candidates.Length == 0) return null;
        if (candidates.Length != 1)
            throw new NotSupportedException("Expected one " + name + " in " + methods[0].DeclaringType);
        return candidates[0];
    }

    private static HookCallback FindCallback(MethodInfo method, string name, int defaultPriority,
        string ownerId, string[] before, string[] after)
    {
        if (method == null) return null;
        if (method.ReturnType != typeof(void) &&
            !(name == "Prefix" && method.ReturnType == typeof(bool)) &&
            !(name == "Finalizer" && method.ReturnType == typeof(Exception)))
            throw new NotSupportedException("Unsupported Harmony callback return type: " + method);
        // The dispatcher checks accepted injections against the exact target signature.
        foreach (var p in method.GetParameters())
            if (p.Name != "__result" && p.Name != "__instance" && p.Name != "__runOriginal" &&
                !(p.Name == "__exception" && name == "Finalizer") &&
                !p.Name.StartsWith("___", StringComparison.Ordinal) &&
                !(p.Name == "__args" && p.ParameterType == typeof(object[])) &&
                p.Name != "__state" &&
                p.Name.StartsWith("__", StringComparison.Ordinal) &&
                !int.TryParse(p.Name.Substring(2), out _))
                throw new NotSupportedException("Unsupported Harmony callback parameter: " + method + " " + p.Name);
        return new HookCallback(method, method.GetCustomAttribute<HarmonyPriority>(false)?.Priority ?? defaultPriority,
            ownerId, method.GetCustomAttribute<HarmonyBefore>(false)?.Owners ?? before,
            method.GetCustomAttribute<HarmonyAfter>(false)?.Owners ?? after);
    }

    private static ParameterInfo StateParameter(HookCallback callback) =>
        callback?.Method.GetParameters().SingleOrDefault(p => p.Name == "__state");

    private static bool CanReadState(ParameterInfo reader, ParameterInfo writer) =>
        reader == null || (writer != null && !reader.ParameterType.IsByRef &&
            writer.ParameterType.GetElementType() == reader.ParameterType);

    internal static void Remove(LoadedMod mod)
    {
        lock (Gate)
        {
            if (mod.Assembly == null || !Scopes.TryGetValue(mod.Assembly, out var scope)) return;
            Scopes.Remove(mod.Assembly);
            foreach (var id in scope.Owners.Keys) StaticModHooks.RemoveOwner(scope.Key(id));
        }
    }
}
#endif
