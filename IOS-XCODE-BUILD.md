# Xcode build validation

Run **Build iOS App** from GitHub Actions after pushing the workflow. The job exports the Unity project, builds the `Unity-iPhone` scheme for a generic iOS device with code signing disabled, and packages the resulting `.app` as `ios-unsigned-ipa`. It retains `ios-xcode-project` and uploads `ios-xcode-build-log` if a later step fails.

An unsigned IPA is a build artifact, not directly installable on a normal iPhone. Device testing requires a separate signing method and an appropriate Apple certificate/profile. This workflow uses no signing secrets. A green job establishes that Xcode compiled the native app; it does not verify launch, mod behavior, graphics, or installation.

The Xcode project path and scheme come from Unity's exported iOS layout. The job uses `CODE_SIGNING_ALLOWED=NO` for compilation, checks that exactly one Release iPhoneOS app was produced, verifies its `Info.plist`, and tests the ZIP archive before upload. An Xcode failure leaves the Unity export available and uploads the captured build log.

References: [Unity iOS build process](https://docs.unity3d.com/2021.3/Documentation/Manual/BuildSettingsiOS.html), [Apple Xcode command-line tool reference](https://developer.apple.com/documentation/xcode/xcode-command-line-tool-reference), [GitHub hosted macOS runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).
