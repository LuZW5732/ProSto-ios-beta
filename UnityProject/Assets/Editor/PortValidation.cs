using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

// Batch-mode validation only. Never enters Play Mode or writes game saves.
public static class PortValidation
{
    [Serializable]
    private sealed class Report
    {
        public string unityVersion;
        public int lootTables;
        public int lootGroups;
        public int shaders;
        public List<string> errors = new List<string>();
    }

    public static void Run()
    {
        var report = new Report { unityVersion = Application.unityVersion };
        try
        {
            AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
            foreach (var guid in AssetDatabase.FindAssets("t:LootTable"))
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                var table = AssetDatabase.LoadAssetAtPath<LootTable>(path);
                report.lootTables++;
                if (table == null || table.table == null || table.table.ItemCount == 0)
                    report.errors.Add("Unreadable/empty loot table: " + path);
            }
            foreach (var guid in AssetDatabase.FindAssets("t:TableGroup"))
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                var group = AssetDatabase.LoadAssetAtPath<TableGroup>(path);
                report.lootGroups++;
                if (group == null || group.tableGroup == null || group.tableGroup.ItemCount == 0)
                    report.errors.Add("Unreadable/empty loot group: " + path);
            }
            if (report.lootTables != 13 || report.lootGroups != 2)
                report.errors.Add("Loot asset counts do not match the captured baseline (13 tables / 2 groups).");
            foreach (var guid in AssetDatabase.FindAssets("t:Shader"))
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                if (!path.StartsWith("Assets/", StringComparison.Ordinal)) continue;
                report.shaders++;
                if (File.ReadAllText(path).Contains("DummyShaderTextExporter"))
                    report.errors.Add("Placeholder shader: " + path);
                var shader = AssetDatabase.LoadAssetAtPath<Shader>(path);
                if (shader == null || ShaderUtil.ShaderHasError(shader))
                    report.errors.Add("Shader import/compiler error: " + path);
            }
            foreach (var scene in EditorBuildSettings.scenes)
            {
                if (!scene.enabled) continue;
                var loaded = EditorSceneManager.OpenScene(scene.path, OpenSceneMode.Single);
                foreach (var root in loaded.GetRootGameObjects())
                foreach (var transform in root.GetComponentsInChildren<Transform>(true))
                    if (GameObjectUtility.GetMonoBehavioursWithMissingScriptCount(transform.gameObject) > 0)
                        report.errors.Add("Missing scene script: " + scene.path + " / " + transform.name);
            }
        }
        catch (Exception error) { report.errors.Add(error.ToString()); }
        System.IO.Directory.CreateDirectory("PortReports");
        File.WriteAllText("PortReports/unity-validation.json", JsonUtility.ToJson(report, true));
        if (report.errors.Count > 0)
            throw new Exception("Port validation failed: " + report.errors.Count + " findings. See PortReports/unity-validation.json.");
    }
}
