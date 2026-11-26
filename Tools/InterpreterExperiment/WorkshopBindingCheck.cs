using System;
using System.Collections.Generic;
using System.Linq;
using dnlib.DotNet;

// Run against assemblies compiled for this port.
internal static class WorkshopBindingCheck
{
    public static void Verify(string gamePath, string modPath, string harmonyPath = null)
    {
        var context = ModuleDef.CreateModuleContext();
        var resolver = (AssemblyResolver)context.AssemblyResolver;
        using var game = ModuleDefMD.Load(gamePath, context);
        resolver.AddToCache(game.Assembly);
        using var harmony = harmonyPath == null ? null : ModuleDefMD.Load(harmonyPath, context);
        if (harmony != null) resolver.AddToCache(harmony.Assembly);
        using var mod = ModuleDefMD.Load(modPath, context);
        VerifyReferences(mod, game.Assembly);
        if (harmony != null) VerifyReferences(mod, harmony.Assembly);
    }

    private static void VerifyReferences(ModuleDefMD mod, AssemblyDef dependency)
    {
        var references = mod.GetAssemblyRefs().Where(r => r.Name == dependency.Name).ToArray();
        if (references.Length != 1 || references[0].FullName != dependency.FullName)
            throw new InvalidOperationException($"{mod.Assembly.Name}: expected dependency {dependency.FullName}");
        var missing = new List<string>();
        int count = 0;
        foreach (var member in mod.GetMemberRefs())
        {
            if (member.DeclaringType?.DefinitionAssembly?.Name != dependency.Name) continue;
            count++;
            if (member.Resolve()?.DeclaringType?.DefinitionAssembly?.FullName != dependency.FullName)
                missing.Add(member.FullName);
        }
        foreach (var item in missing) Console.WriteLine("Unresolved: " + item);
        Console.WriteLine($"{mod.Assembly.Name}: {count - missing.Count}/{count} {dependency.Name} member references resolved");
        if (missing.Count != 0 || count == 0)
            throw new MissingMemberException($"{mod.Assembly.Name} -> {dependency.Name}: " + string.Join(", ", missing));
    }
}
