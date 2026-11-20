# iOS bundled mods (2026-11-14)

Item Details 0.9.6 and Smart Inventory Arrange 1.0.1 are compiled into Assembly-CSharp. Exact upstream commits are in BUNDLED-MOD-SOURCES.json; upstream notices and licenses are in UnityProject/ThirdPartyNotices. The IPA analysis suggested direct game-source callbacks with an offline catalog; this implementation uses our own static callback registry.

The catalog registers both mods in the existing Mods panel. First launch enables them once; saved enable/disable choices take effect after restart. Configurations use the game's existing configuration APIs. iOS hides desktop folder/workshop/unsubscribe controls. Localization, manifests and the arrangement model ship in StreamingAssets/PortMods.

62 game methods have explicit build-time callback entries. Supported callbacks include prefix cancellation, postfix, finalizer, priorities, per-invocation state and argument/result updates. Ownership and disposal are explicit. Unsupported targets and IL transpilers fail instead of silently succeeding. AnimalGenes and tooltip value memoization transpilers were converted to source edits. Third-party callback IL evidence scanning conservatively returns false on AOT. ITEMDETAILS_SELFTEST is not enabled.

This is not a runtime Harmony implementation or an arbitrary DLL loader. Future mods need source integration and reviewed callback entries; JIT support remains a separate project. The original Harmony plugin is excluded from iOS, while desktop loader branches remain. Reflection-only game/mod members are retained by Assets/PortModPreservation/link.xml, initially preserving all Assembly-CSharp members; size/performance tuning remains after functional validation.

Validation completed locally: C# 9 desktop and UNITY_IOS compilations, 18 standalone callback assertions, and metadata-only confirmation that the iOS assembly references neither Harmony nor MonoMod. This does not execute Unity or prove IL2CPP/iPhone behavior. Next: Actions iOS export, then manual device checks of startup, both tooltip modes, sorting menus, settings persistence, restart-based enable/disable, and arrangement rollback. No game saves were modified by these tests.

Preparation tools and standalone tests are included under Tools/StaticMods. Their original workspace paths expect ios-port/local/cloud-repo and pinned archives under ios-port/local/mod-sources; this is source provenance, not a turnkey recovery of the commercial game. The generator is repeatable and reports already-wrapped entries; the host adapter intentionally refuses repeated application. The complete prepared Unity source is the build input.

Unity reference for reflection preservation: https://docs.unity.cn/2021.3/Documentation/Manual/managed-code-stripping.html
