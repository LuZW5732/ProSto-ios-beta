# Probably Stolen iOS reconstruction

Private recovery workspace from the owner's PC game. Original game assets and code retain their respective owners' rights; this repository does not grant redistribution rights.

Unity version: 2021.3.45f2. This is an incomplete recovered project, not a playable iOS release.

The validation workflow imports the project using the iOS target and calls `PortValidation.Run`. It does not build an IPA or enter Play Mode. Unresolved issues include shader validation on Unity/Metal, missing serialized references, Windows Addressables content, and unverified IL2CPP compatibility.

Configure repository Actions secrets `UNITY_LICENSE`, `UNITY_EMAIL`, and `UNITY_PASSWORD`. Never commit credentials or license files. The workflow runs on pushes to main and can also be started manually. Reports and available build logs are retained for seven days.

13 loot tables and 2 table groups were restored from a read-only runtime capture. 28 shader placeholders were replaced with official package candidates; another 23 now use HLSL translated from readable Metal programs in the supplied IPA. Visual equivalence remains unverified. See [shader recovery notes](SHADER-RECOVERY.md). No Steam authorization patches or emulator files are included.
