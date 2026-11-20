using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.Localization;
using UnityEngine.Localization.Settings;
using UnityEngine.Localization.Tables;
using UnityEngine.ResourceManagement.AsyncOperations;

// Recovered source tables are already included in Resources. The copied PC
// Addressables bundles cannot supply these assets on iOS.
internal static class PortLocalizationBootstrap
{
    private const string Root = "emporium/localization";
    // Match MainMenuUIController.LOCALE_DROPDOWN / LocHelper.AUTO_DETECT_LOCALES.
    private static readonly string[] SupportedLocales = { "en", "ja", "de", "ru", "zh", "fr", "es", "pl" };

#if UNITY_IOS
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
#endif
    private static void Initialize()
    {
        var settings = Resources.Load<LocalizationSettings>(Root + "/Localization Settings");
        if (settings == null) throw new InvalidOperationException("Missing recovered Localization Settings");
        var locales = Resources.LoadAll<Locale>(Root).Where(l => SupportedLocales.Contains(l.Identifier.Code)).ToArray();
        var tables = Resources.LoadAll<StringTable>(Root);
        if (locales.Length == 0 || tables.Length == 0)
            throw new InvalidOperationException("Recovered localization locales/tables are empty");
        // No localized asset tables exist in this recovered game. Fail visibly
        // if a future game update adds them rather than silently dropping them.
        if (Resources.LoadAll<AssetTable>(Root).Length != 0)
            throw new NotSupportedException("Localized asset tables require a resource adapter");
        var previous = settings.GetStringDatabase();
        var database = new ResourceStrings(tables) {
            SmartFormatter = previous.SmartFormatter,
            MissingTranslationState = previous.MissingTranslationState,
            NoTranslationFoundMessage = previous.NoTranslationFoundMessage,
            UseFallback = previous.UseFallback,
            DefaultTable = previous.DefaultTable
        };
        settings.SetAvailableLocales(new ResourceLocales(locales));
        settings.SetStringDatabase(database);
        settings.SetAssetDatabase(new EmptyAssetDatabase());
        LocalizationSettings.Instance = settings;
        Debug.Log($"[iOS Port] Resource localization ready: {settings.GetAvailableLocales().Locales.Count} locales, {database.TableCount} tables.");
    }

    private sealed class ResourceLocales : ILocalesProvider
    {
        public List<Locale> Locales { get; } = new List<Locale>();
        public ResourceLocales(IEnumerable<Locale> locales)
        {
            foreach (var locale in locales.OrderBy(l => l.name, StringComparer.Ordinal)) AddLocale(locale);
        }
        public Locale GetLocale(LocaleIdentifier id) => Locales.Find(l => l.Identifier == id);
        public void AddLocale(Locale locale)
        {
            if (locale != null && GetLocale(locale.Identifier) == null) Locales.Add(locale);
        }
        public bool RemoveLocale(Locale locale) => Locales.Remove(locale);
    }

    private sealed class ResourceStrings : LocalizedStringDatabase, IPreloadRequired
    {
        private readonly Dictionary<(string, string), StringTable> tables = new Dictionary<(string, string), StringTable>();
        private readonly Dictionary<StringTable, AsyncOperationHandle<StringTable>> handles = new Dictionary<StringTable, AsyncOperationHandle<StringTable>>();
        private readonly Dictionary<string, AsyncOperationHandle<IList<StringTable>>> lists = new Dictionary<string, AsyncOperationHandle<IList<StringTable>>>();
        private readonly AsyncOperationHandle ready = Addressables.ResourceManager.CreateCompletedOperation(true, null);
        public int TableCount => handles.Count;
        AsyncOperationHandle IPreloadRequired.PreloadOperation => ready;

        public ResourceStrings(IEnumerable<StringTable> sources)
        {
            foreach (var table in sources.OrderBy(t => t.name, StringComparer.Ordinal))
            {
                if (table.SharedData == null) throw new InvalidOperationException("Missing shared data: " + table.name);
                var key = (table.LocaleIdentifier.Code, table.TableCollectionName);
                if (tables.TryGetValue(key, out var existing))
                {
                    // AssetRipper may export the same table twice. Do not choose
                    // silently if the two copies contain different translations.
                    if (existing.Count != table.Count || existing.Values.Any(e => table.GetEntry(e.KeyId)?.LocalizedValue != e.LocalizedValue))
                        throw new InvalidOperationException("Conflicting recovered string tables: " + key);
                    continue;
                }
                tables.Add(key, table);
                tables[(key.Item1, table.SharedData.TableCollectionNameGuid.ToString("N"))] = table;
                handles[table] = Addressables.ResourceManager.CreateCompletedOperation(table, null);
            }
        }

        public override AsyncOperationHandle<StringTable> GetTableAsync(TableReference reference, Locale locale = null)
        {
            locale = locale ?? LocalizationSettings.SelectedLocale;
            var name = reference.ReferenceType == TableReference.Type.Guid
                ? reference.TableCollectionNameGuid.ToString("N") : reference.TableCollectionName;
            if (locale == null || string.IsNullOrEmpty(name) || !tables.TryGetValue((locale.Identifier.Code, name), out var table))
                throw new InvalidOperationException($"Missing recovered localization table: {locale?.Identifier.Code}/{name}");
            return handles[table];
        }
        public override StringTable GetTable(TableReference reference, Locale locale = null) => GetTableAsync(reference, locale).Result;
        public override bool IsTableLoaded(TableReference reference, Locale locale = null)
        {
            locale = locale ?? LocalizationSettings.SelectedLocale;
            var name = reference.ReferenceType == TableReference.Type.Guid ? reference.TableCollectionNameGuid.ToString("N") : reference.TableCollectionName;
            return locale != null && name != null && tables.ContainsKey((locale.Identifier.Code, name));
        }
        public override AsyncOperationHandle<IList<StringTable>> GetAllTables(Locale locale = null)
        {
            locale = locale ?? LocalizationSettings.SelectedLocale;
            if (locale == null) throw new InvalidOperationException("No selected locale");
            var code = locale.Identifier.Code;
            if (!lists.TryGetValue(code, out var handle))
            {
                IList<StringTable> result = handles.Keys.Where(t => t.LocaleIdentifier.Code == code).ToList();
                handle = Addressables.ResourceManager.CreateCompletedOperation(result, null);
                lists.Add(code, handle);
            }
            return handle;
        }
    }

    private sealed class EmptyAssetDatabase : LocalizedAssetDatabase, IPreloadRequired
    {
        private readonly AsyncOperationHandle ready = Addressables.ResourceManager.CreateCompletedOperation(true, null);
        AsyncOperationHandle IPreloadRequired.PreloadOperation => ready;
    }
}
