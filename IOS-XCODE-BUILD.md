# Local iOS build on macOS

`ProbablyStolen-ios` uses the VMware macOS runner for local builds. `ProSto-ios-beta` uses GitHub Actions. Keep the Unity project, assets, and build scripts in sync between the repositories. Keep trigger differences in `.github/workflows/` and install the SSH sync task and Git hook only in the Windows checkout used for local builds.

After fetching both remotes, check that only workflow configuration differs. In a checkout where `origin` is `ProbablyStolen-ios` and `beta` is `ProSto-ios-beta`, run:

```sh
git diff --exit-code origin/main beta/main -- . ':(exclude).github/workflows/**'
```

Use the macOS virtual machine with Unity 2021.3.45f2, iOS Build Support, an activated Unity Editor, and Xcode 16.4 with its iOS 18.5 platform. Close any Unity Editor window that has this project open. From the repository root, run:

```sh
bash Tools/build-ios-local.sh
```

The script exports the enabled Unity scenes through `PortIosExport.Run`, compiles the Xcode project for an iOS device with signing disabled, and checks the IPA archive before replacing `build/local-ios/ProbablyStolen-unsigned.ipa`. Each run keeps its Xcode export, intermediate build files, and logs under `build/local-ios/run.*`. A failed run leaves the previous successful IPA available. Use the same signing method as for the manually tested IPA when installing on a phone.

Xcode is selected from `/Applications/Xcode.app` by default. If it is installed elsewhere, set `DEVELOPER_DIR` to that Xcode installation's `Contents/Developer` directory when invoking the script. For a VM missing the iOS 18.5 platform, run `xcodebuild -downloadPlatform iOS -buildVersion 18.5` before building.

## Start a VM build after each Windows commit

Enable macOS Remote Login for the build user on the VM's VMware NAT network. Set up SSH public key authentication from Windows and verify the Mac host key on first connection. The Windows task uses noninteractive SSH, so confirm that `ssh -o BatchMode=yes USER@MAC_ADDRESS /usr/bin/true` succeeds under the same Windows account.

On the Mac, copy `Tools/ios-vm-worker.sh` to a convenient location and run it with `--install` while logged in. The installer creates a launch agent and a local checkout and repository under `~/ProbablyStolenBuild`. The VMware share can be used to copy this small installer once.

From this checkout on Windows, install the commit hook and the per-user sync task. Set the destination to the VM's VMware NAT address:

```powershell
.\Tools\install-ios-vm-host.ps1 -MacDestination builder@192.0.2.10
```

The first commit must include the local build files. The hook queues the exact revision in the Windows Git repository. Once per minute while Windows is logged in, the task sends queued revisions by Git over SSH and downloads each new result as a single archive stream over SSH. Queued commits remain local if the Mac is offline. The Mac builds one revision at a time on its own disk. Source objects, intermediate files, logs, and IPAs travel over SSH or stay on local disk throughout builds.

Windows results are under `build/vm-results`, one directory per request. See `build/vm-sync.log` for the most recent transfer and `~/ProbablyStolenBuild/runner.log` on the Mac for worker status. `bash Tools/ios-vm-host.sh queue` requests another build of the current commit, and `bash Tools/ios-vm-host.sh sync` runs a transfer immediately.

## GitHub Actions on ProSto-ios-beta

Run **Build iOS App** from GitHub Actions after pushing the workflow. The job exports the Unity project, builds the `Unity-iPhone` scheme for a generic iOS device with code signing disabled, and packages the resulting `.app` as `ios-unsigned-ipa`. It retains `ios-xcode-project` and uploads `ios-xcode-build-log` if a later step fails.

An unsigned IPA is a build artifact, not directly installable on a normal iPhone. Device testing requires a separate signing method and an appropriate Apple certificate/profile. This workflow uses no signing secrets. A green job establishes that Xcode compiled the native app; it does not verify launch, mod behavior, graphics, or installation.

The Xcode project path is `build/iOS/iOS/Unity-iPhone.xcodeproj` in game-ci's output (the outer `iOS` is its platform directory, the inner `iOS` is Unity's export directory). The job uses the `Unity-iPhone` scheme and `CODE_SIGNING_ALLOWED=NO` for compilation, checks that exactly one Release iPhoneOS app was produced, verifies its `Info.plist`, and tests the ZIP archive before upload. An Xcode failure leaves the Unity export available and uploads the captured build log.

References: [Unity iOS build process](https://docs.unity3d.com/2021.3/Documentation/Manual/BuildSettingsiOS.html), [Apple Xcode command-line tool reference](https://developer.apple.com/documentation/xcode/xcode-command-line-tool-reference), [GitHub hosted macOS runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).
