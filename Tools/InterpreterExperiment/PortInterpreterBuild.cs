using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
using HarmonyLib;
using HybridCLR.Editor;
using HybridCLR.Editor.Commands;
using HybridCLR.Editor.Installer;
using HybridCLR.Editor.Settings;
using ProbablyStolen.Port.Mods;
using UnityEditor;
using UnityEngine;

public static class PortInterpreterBuild
{
    private static readonly string WorkshopFolder = Path.GetFullPath("WorkshopReference");
    private static readonly string ShutterFolder = Path.Combine(WorkshopFolder, "ShutterEvents");
    private static readonly string ReputationFolder = Path.Combine(WorkshopFolder, "ReputationPop");
    private static readonly string ReputationDll = Path.Combine(ReputationFolder, "ReputationPop.dll");
    private static readonly string PurchaseFolder = Path.Combine(WorkshopFolder, "PurchaseStayCounter");
    private static readonly string PurchaseDll = Path.Combine(PurchaseFolder, "PurchaseStayCounter.dll");
    private const BindingFlags LoaderFlags = BindingFlags.Static | BindingFlags.NonPublic;

    public static void VerifyInput()
    {
        var game = typeof(PlayerStore).Assembly.Location;
        WorkshopBindingCheck.Verify(game, Path.Combine(ShutterFolder, "ShutterEvents.dll"));
        if (System.IO.Directory.Exists(ReputationFolder))
            WorkshopBindingCheck.Verify(game, ReputationDll, typeof(HarmonyPatch).Assembly.Location);
        if (File.Exists(PurchaseDll))
            WorkshopBindingCheck.Verify(game, PurchaseDll, typeof(HarmonyPatch).Assembly.Location);
    }

    // Editor Mono test only. Used separately from the IL2CPP generation step.
    public static void VerifyLifecycle()
    {
        VerifyInput();
        // Set up the game assembly names before scanning workshop DLLs.
        var names = typeof(ModLoader).GetMethod("CollectGameAssemblyNames", LoaderFlags).Invoke(null, null);
        typeof(ModLoader).GetField("gameAssemblyNames", LoaderFlags).SetValue(null, names);
        var runtime = typeof(ModLoader).Assembly.GetType("PortInterpretedMods", true);
        var start = runtime.GetMethod("Start", LoaderFlags);
        var stop = runtime.GetMethod("Stop", LoaderFlags);
        VerifyShutterLifecycle(start, stop);
        if (File.Exists(ReputationDll)) VerifyReputationLifecycle(start, stop);
    }

    private static LoadedMod ReadMod(string folder)
    {
        var manifest = ModLoader.ParseManifestForTools(folder, out var issue);
        if (manifest == null) throw new InvalidDataException(issue);
        return new LoadedMod { Manifest = manifest, FolderPath = folder };
    }

    private static void VerifyShutterLifecycle(MethodInfo start, MethodInfo stop)
    {
        var mod = ReadMod(ShutterFolder);
        var sceneObject = new GameObject("Workshop locale check");
        sceneObject.SetActive(false);
        try
        {
            var loader = sceneObject.AddComponent<ModLoader>();
            typeof(ModLoader).GetMethod("LoadLocalization", BindingFlags.NonPublic | BindingFlags.Instance)
                .Invoke(loader, new object[] { mod });
            if (mod.Localization["zh"]["title"] != "今日事件" || !mod.Localization.ContainsKey("en"))
                throw new InvalidDataException("Workshop localization missing");
        }
        finally { UnityEngine.Object.DestroyImmediate(sceneObject); }

        var events = new[] { "OnWakingUpLate", "OnGameLoadedLate", "OnShutterOpenedLate", "OnShutterClosedEarly",
            "OnShutterClosedLate", "OnGoingSleepEarly", "OnModConfigApplied" };
        WithEnabledMod(mod, start, stop, () => CheckHandlers(mod, events, 1));
        CheckEnabled(mod, false);
        CheckHandlers(mod, events, 0);
        Debug.Log("Workshop lifecycle PASS: ShutterEvents, en/zh, seven subscriptions and cleanup");
    }

    private static void VerifyReputationLifecycle(MethodInfo start, MethodInfo stop)
    {
        var mod = ReadMod(ReputationFolder);
        var events = new[] { "OnGameLoadedEarly", "OnGoingSleepEarly" };
        var target = typeof(StoreReputation).GetMethod(nameof(StoreReputation.OnItemTraded));
        if (StaticModHooks.HasHooks(target)) throw new InvalidOperationException("Reputation trade hooks already present");

        // Seed only the fields the trade path reads. The PlayerStore constructor resets live game state.
        const string faction = "PORT_WORKSHOP_TEST";
        var reputation = new StoreReputation { factionId = faction };
        var store = (PlayerStore)FormatterServices.GetUninitializedObject(typeof(PlayerStore));
        store.storeReputations = new List<StoreReputation> { reputation };
        store.startingPerks = new List<StartingPerk>();
        var instance = typeof(PlayerStore).GetField("instance", LoaderFlags);
        var previous = instance.GetValue(null);
        instance.SetValue(null, store);
        try
        {
            var client = new StoreClient();
            void Trade() => StoreReputation.OnItemTraded(faction, 400, 400, client, true, null);
            Trade();
            double vanillaDelta = reputation.GetReputationExact();
            if (vanillaDelta <= 0) throw new InvalidOperationException("Fixture trade did not change reputation");

            Dictionary<string, double> pending = null;
            WithEnabledMod(mod, start, stop, () =>
            {
                CheckHandlers(mod, events, 1);
                if (!StaticModHooks.HasHooks(target)) throw new InvalidOperationException("Reputation trade hooks missing");

                var pop = mod.Assembly.GetType("ReputationPop.Pop", true);
                pending = (Dictionary<string, double>)pop.GetField("pending", LoaderFlags).GetValue(null);
                // Keep the recorded delta in the queue without scheduling an animation in Edit Mode.
                pop.GetField("scheduled", LoaderFlags).SetValue(null, true);
                double before = reputation.GetReputationExact();
                Trade();
                double delta = reputation.GetReputationExact() - before;
                if (!pending.TryGetValue(faction, out double recorded) || Math.Abs(recorded - delta) > 1e-9 ||
                    Math.Abs(delta - vanillaDelta) > 1e-9)
                    throw new InvalidOperationException("Reputation pop did not record the vanilla trade delta");
            });
            CheckEnabled(mod, false);
            CheckHandlers(mod, events, 0);
            if (StaticModHooks.HasHooks(target) || pending.Count != 0)
                throw new InvalidOperationException("Reputation pop state survived disable");
            double after = reputation.GetReputationExact();
            Trade();
            if (Math.Abs(reputation.GetReputationExact() - after - vanillaDelta) > 1e-9 || pending.Count != 0)
                throw new InvalidOperationException("Post-disable trade did not match vanilla behavior");
        }
        finally { instance.SetValue(null, previous); }
        Debug.Log("Workshop lifecycle PASS: ReputationPop, trade prefix state, recorded delta and cleanup");
    }

    private static void WithEnabledMod(LoadedMod mod, MethodInfo start, MethodInfo stop, Action verify)
    {
        var records = (List<LoadedMod>)typeof(ModLoader).GetField("mods", LoaderFlags).GetValue(null);
        records.Add(mod);
        try
        {
            start.Invoke(null, new object[] { mod });
            try
            {
                CheckEnabled(mod, true);
                verify();
            }
            finally { stop.Invoke(null, new object[] { mod }); }
        }
        finally { records.Remove(mod); }
    }

    private static void CheckEnabled(LoadedMod mod, bool enabled)
    {
        if (mod.IsEnabled != enabled || (mod.Instance != null) != enabled)
            throw new InvalidOperationException(mod.Manifest.ID + ": incorrect lifecycle state");
    }

    private static void CheckHandlers(LoadedMod mod, string[] events, int expected)
    {
        foreach (string name in events)
        {
            var field = typeof(ModHook).GetField(name, LoaderFlags);
            var handlers = (Delegate)field.GetValue(null);
            int count = handlers?.GetInvocationList().Count(h => h.Method.DeclaringType.Assembly == mod.Assembly) ?? 0;
            if (count != expected)
                throw new InvalidOperationException($"{mod.Manifest.ID}: {name} has {count} mod subscriptions, expected {expected}");
        }
    }

    public static void Generate()
    {
        VerifyInput();
        var settings = HybridCLRSettings.Instance;
        settings.enable = true;
        var fixtures = new[] { Path.Combine(ShutterFolder, "ShutterEvents.dll"), ReputationDll, PurchaseDll }
            .Where(File.Exists).ToArray();
        settings.hotUpdateAssemblies = fixtures.Select(Path.GetFileNameWithoutExtension).ToArray();
        settings.hotUpdateAssemblyDefinitions = new UnityEditorInternal.AssemblyDefinitionAsset[0];
        settings.externalHotUpdateAssembliyDirs = fixtures.Select(Path.GetDirectoryName).ToArray();
        settings.hybridclrRepoURL = "https://github.com/focus-creative-games/hybridclr";
        settings.il2cppPlusRepoURL = "https://github.com/focus-creative-games/il2cpp_plus";
        HybridCLRSettings.Save();
        PlayerSettings.SetApiCompatibilityLevel(BuildTargetGroup.iOS, ApiCompatibilityLevel.NET_Unity_4_8);
        var installer = new InstallerController();
        if (!installer.HasInstalledHybridCLR()) installer.InstallDefaultHybridCLR();
        PrebuildCommand.GenerateAll();
    }

    // Separate editor invocation: Unity has compiled the generated reference list.
    public static void CopyMetadata()
    {
        var type = typeof(PlayerStore).Assembly.GetType("AOTGenericReferences", true);
        var names = (IEnumerable<string>)type.GetField("PatchedAOTAssemblyList").GetValue(null);
        var source = SettingsUtil.GetAssembliesPostIl2CppStripDir(BuildTarget.iOS);
        var dest = Path.Combine(Application.streamingAssetsPath, "PortInterpreterMetadata");
        System.IO.Directory.CreateDirectory(dest);
        foreach (var name in names)
            File.Copy(Path.Combine(source, name), Path.Combine(dest, name + ".bytes"), true);
        AssetDatabase.Refresh();
    }
}
