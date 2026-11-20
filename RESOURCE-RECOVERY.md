# Resource recovery fixes, 2026-11-15

Device reports (iPhone 16 Plus, iOS 26.3, LiveContainer) show localization keys such as `ui_endofday_info`, `mech_day_label`, and `generalist_body`, unchanged English UI after locale selection, and incomplete shutter/storage visuals.

## Localization

Original IPA comparison: its `Data/Raw/aa/settings.json` targets iOS and its locale bundles are under `aa/iOS`. It uses rebuilt iOS Addressables, not the Resources adapter below. Read-only comparison of all 168 StringTable/SharedTableData objects against the current PC recovery found 99 identical and 69 different (including metadata/formatting comparisons); neither side has unmatched table names. Directly copying those old bundles would therefore replace current-version content. The current adapter is an alternative candidate using current PC data, not a claim to duplicate the IPA's localization implementation. Detailed local evidence: `ios-port/local/ipa-localization-comparison.json`, produced by `compare_ipa_localization.py`.

StreamingAssets/aa contains the copied StandaloneWindows64 catalog/bundles. The recovered project has runtime Localization/Addressables DLLs, without their editor packages or the original group definitions. Antigravity independently reviewed the mismatched target and localization call path; its subsequent implementation request returned no report or changes. Codex implemented the resource adapter below.

The actual Locale, StringTable, and SharedTableData assets already exist under Resources/emporium/localization. PortLocalizationBootstrap replaces the locale/string providers before scene loading on iOS, so existing Unity Localization consumers, locale-change notifications and Smart String formatting read compiled Resources assets. The original SmartFormatter and missing-translation settings are retained. No translated text is hardcoded or fabricated. The available locale list matches the game's eight menu languages; Italian, Korean and Portuguese placeholder tables are not advertised.

There are no localized AssetTables in this recovery; the adapter skips their Addressables preload and fails explicitly if a later recovery introduces them. All string tables are loaded once and retained for the session, trading memory for reliable synchronous UI access. Future asset-localization support and resource lifecycle optimization need separate work.

## Sprite resource paths

The PC ResourceManager maps many Sprite subassets to a shared atlas path. AssetRipper exported these sprites separately, so Resources.LoadAll<Sprite>("Window/background") no longer enumerates the original set. The original IPA also contains a RestoredSpriteResources adapter.

restore_sprite_resources.py reads the PC globalgamemanagers index with UnityPy and matches Sprite render-data GUID/local IDs and names to recovered .asset files. It generated 1,321 entries with zero unmatched sprites. PortSpriteResources.asset stores the Unity object references; RenderHandler and PaperAssets use that index. Original aliases are case insensitive, folder lookups include descendants, and single-resource lookups match the exact path. Unknown paths retain Unity Resources fallback behavior. The window background atlas contains 21 sprites; the border atlas contains 11.

## Validation and remaining work

Static data checks: 154 unique language/table pairs, duplicate exports agree, and the three reported keys exist in each of the eight supported languages. C# compilation is checked separately. PortResourceBuildCheck runs during iOS export and validates actual Unity-loaded translations and sprite references before building.

These checks do not establish correct device rendering or shutter movement. Device testing must cover locale changes, formatted day numbers, new-game text, window borders/storage grids and opening the shutter. The original IPA's PortInput, PortGestureMachine, PortTouchToolbar, PortUIInput and PortTwoFingerRouter establish that a separate mobile input/toolbar layer is required; it is not implemented by these resource fixes. No mobile layout completion is claimed.
