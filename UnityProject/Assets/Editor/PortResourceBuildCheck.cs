using System;
using System.Linq;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;
using UnityEngine.Localization;
using UnityEngine.Localization.Tables;

// Validate recovered source content before spending time exporting/building iOS.
public sealed class PortResourceBuildCheck : IPreprocessBuildWithReport
{
    public int callbackOrder => -100;
    public void OnPreprocessBuild(BuildReport report)
    {
        if (report.summary.platform != BuildTarget.iOS) return;
        const string root = "emporium/localization";
        var tables = Resources.LoadAll<StringTable>(root);
        var available = Resources.LoadAll<Locale>(root).Select(l => l.Identifier.Code).Distinct().ToArray();
        var locales = new[] { "en", "ja", "de", "ru", "zh", "fr", "es", "pl" };
        if (locales.Any(code => !available.Contains(code))) throw new BuildFailedException("Recovered locale inventory is incomplete");
        if (Resources.LoadAll<AssetTable>(root).Length != 0)
            throw new BuildFailedException("Localized asset tables need explicit resource support");
        foreach (var group in tables.GroupBy(t => (t.LocaleIdentifier.Code, t.TableCollectionName)))
        {
            var first = group.First();
            foreach (var other in group.Skip(1))
                if (first.Count != other.Count || first.Values.Any(e => other.GetEntry(e.KeyId)?.LocalizedValue != e.LocalizedValue))
                    throw new BuildFailedException("Conflicting recovered translations: " + group.Key);
        }
        foreach (var locale in locales)
        {
            Require("UI", "ui_endofday_info", locale);
            Require("Mechanic", "mech_day_label", locale);
            Require("NewGame", "generalist_body", locale);
        }
        var index = Resources.Load<PortSpriteResources>("PortSpriteResources");
        if (index == null || index.entries == null || index.entries.Length < 1300 || index.entries.Any(e => e.sprite == null))
            throw new BuildFailedException("Recovered sprite index is missing or contains unresolved assets");
        if (!index.entries.Any(e => e.path == "window/background" && e.sprite.name == "black") ||
            !index.entries.Any(e => e.path == "window/border" && e.sprite.name == "inside"))
            throw new BuildFailedException("Window sprite atlas aliases are incomplete");
        Debug.Log($"[PortResourceBuildCheck] {locales.Length} locales, {tables.Length} exported tables, {index.entries.Length} sprite aliases verified.");

        void Require(string collection, string key, string code)
        {
            var table = tables.FirstOrDefault(t => t.LocaleIdentifier.Code == code && t.TableCollectionName == collection);
            var entry = table?.GetEntry(key);
            if (entry == null || string.IsNullOrEmpty(entry.LocalizedValue) || entry.LocalizedValue == key)
                throw new BuildFailedException($"Missing recovered translation: {code}/{collection}/{key}");
        }
    }
}
