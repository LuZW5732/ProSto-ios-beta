using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;

namespace ProbablyStolen.Port.Mods
{
    // The catalog is deliberately closed: adding a mod requires a reviewed build.
    // A future dynamic loader can share lifecycle/configuration without pretending
    // that arbitrary DLL loading or machine-code patching is available today.
    internal static class BundledModCatalog
    {
        private sealed class Definition
        {
            internal string Id, Folder;
            internal Func<IMod> Factory;
        }
        private static readonly Definition[] Definitions = {
            new Definition { Id = "item_details", Folder = "ItemDetails", Factory = () => new ItemDetails.ModEntry() },
            new Definition { Id = "smart_inventory_arrange", Folder = "SmartInventoryArrange", Factory = () => new SmartInventoryArrange.ModEntry() }
        };
        internal static bool Contains(string id) => Definitions.Any(d => d.Id == id);

        internal static List<LoadedMod> Create()
        {
            var result = new List<LoadedMod>();
            foreach (var definition in Definitions)
            {
                var folder = Path.Combine(Application.streamingAssetsPath, "PortMods", definition.Folder);
                var manifest = ModLoader.ParseManifestForTools(folder, out var problem);
                if (manifest == null || manifest.ID != definition.Id)
                    throw new InvalidOperationException("Bundled manifest invalid: " + definition.Id + ": " + problem);
                // These are sources compiled into the game, not external DLLs.
                manifest.Assemblies.Clear();
                result.Add(new LoadedMod { Manifest = manifest, Instance = definition.Factory(),
                    Assembly = typeof(BundledModCatalog).Assembly, FolderPath = folder, Source = ModSource.Bundled,
                    TrustState = ModTrustState.NotChecked, TrustNote = "Compiled into this game build" });
            }
            return result;
        }

        internal static void Initialize(LoadedMod mod, bool enabled)
        {
            try
            {
                mod.Instance.Init(mod.Manifest);
                if (enabled)
                {
                    mod.IsEnabled = true; // Game ModHelper queries this during OnEnable.
                    mod.Instance.OnEnable();
                }
            }
            catch (Exception error)
            {
                Stop(mod);
                mod.LoadError = error.ToString();
                UnityEngine.Debug.LogError("[BundledMods] " + mod.Manifest.ID + ": " + error);
            }
        }

        internal static void Stop(LoadedMod mod)
        {
            try { mod.Instance?.OnDisable(); }
            catch (Exception error) { UnityEngine.Debug.LogWarning("[BundledMods] Cleanup: " + error); }
            finally
            {
                // Owners used by the two pinned adapters; no assembly-wide removal.
                StaticModHooks.RemoveOwner(mod.Manifest.ID);
                StaticModHooks.RemoveOwner(mod.Manifest.ID + ".context");
                mod.IsEnabled = false;
            }
        }
    }
}
