# Probably Stolen iOS reconstruction

Private recovery workspace from the owner's PC game. Original game assets and code retain their respective owners' rights; this repository does not grant redistribution rights.

Unity version: 2021.3.45f2. This is an incomplete recovered project, not a playable iOS release.

The validation workflow imports the project using the iOS target and calls `PortValidation.Run`. It does not build an IPA or enter Play Mode. Unresolved issues include shader validation on Unity/Metal, missing serialized references, Windows Addressables content, and unverified IL2CPP compatibility.

`ProbablyStolen-ios` builds on the local VMware macOS runner. `ProSto-ios-beta` builds on GitHub Actions. See [iOS build setup](IOS-XCODE-BUILD.md) for local automation and how to compare the two repositories' source trees.

For `ProSto-ios-beta`, configure the Actions secrets `UNITY_LICENSE`, `UNITY_EMAIL`, and `UNITY_PASSWORD`. The validation workflow runs on pushes to `main` and can also be started manually. The separate iOS export workflow starts manually. Reports and available build logs are retained for seven days.

13 loot tables and 2 table groups were restored from a read-only runtime capture. 28 shader placeholders were replaced with official package candidates; another 23 now use HLSL translated from readable Metal programs in the supplied IPA. Visual equivalence remains unverified. See [shader recovery notes](SHADER-RECOVERY.md). No Steam authorization patches or emulator files are included.

Planned for the following iOS release: replace keyboard and mouse operation hints with a touch gesture tutorial based on the controls available in each game context.
