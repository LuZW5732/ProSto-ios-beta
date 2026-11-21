#!/bin/bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
unity_root=/Applications/Unity/Hub/Editor/2021.3.45f2
unity="$unity_root/Unity.app/Contents/MacOS/Unity"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

if [[ $(uname -s) != Darwin ]]; then
    echo 'Run this script on the macOS build machine.' >&2
    exit 1
fi
if [[ ! -x "$unity" || ! -d "$unity_root/PlaybackEngines/iOSSupport" ]]; then
    echo 'Install Unity 2021.3.45f2 and its iOS Build Support module through Unity Hub.' >&2
    exit 1
fi

xcode_version=$(xcodebuild -version)
if [[ ${xcode_version%%$'\n'*} != 'Xcode 16.4' ]]; then
    printf 'Expected Xcode 16.4 at %s. Found:\n%s\n' "$DEVELOPER_DIR" "$xcode_version" >&2
    exit 1
fi
xcrun --sdk iphoneos --show-sdk-version

output="${PORT_IOS_OUTPUT_DIR:-$repo_root/build/local-ios}"
mkdir -p "$output"
run_dir=$(mktemp -d "$output/run.XXXXXXXX")
export PORT_IOS_EXPORT_PATH="$run_dir/Xcode"
unity_log="$run_dir/unity.log"
xcode_log="$run_dir/xcode.log"

printf 'Exporting Unity iOS project. Build files and logs: %s\n' "$run_dir"
if ! "$unity" -batchmode -nographics -quit -buildTarget iOS \
    -projectPath "$repo_root/UnityProject" -executeMethod PortIosExport.Run -logFile "$unity_log"; then
    printf 'Unity export failed. See %s\n' "$unity_log" >&2
    if [[ -f "$unity_log" ]]; then tail -n 30 "$unity_log" >&2; fi
    exit 1
fi

xcode_project="$PORT_IOS_EXPORT_PATH/Unity-iPhone.xcodeproj"
if [[ ! -d "$xcode_project" ]]; then
    printf 'Unity did not produce %s. See %s\n' "$xcode_project" "$unity_log" >&2
    exit 1
fi

echo 'Compiling the unsigned iOS app with Xcode.'
if ! xcodebuild -project "$xcode_project" -scheme Unity-iPhone -configuration Release \
    -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath "$run_dir/DerivedData" \
    CODE_SIGNING_ALLOWED=NO build >"$xcode_log" 2>&1; then
    printf 'Xcode build failed. See %s\n' "$xcode_log" >&2
    tail -n 30 "$xcode_log" >&2
    exit 1
fi

shopt -s nullglob
apps=("$run_dir/DerivedData/Build/Products/Release-iphoneos/"*.app)
if [[ ${#apps[@]} -ne 1 ]]; then
    printf 'Expected one Release iOS app, found %s. See %s\n' "${#apps[@]}" "$xcode_log" >&2
    exit 1
fi

mkdir "$run_dir/Payload"
ditto "${apps[0]}" "$run_dir/Payload/$(basename "${apps[0]}")"
ipa_name=ProbablyStolen-unsigned.ipa
ditto -c -k --keepParent "$run_dir/Payload" "$run_dir/$ipa_name"
unzip -tq "$run_dir/$ipa_name"
mv -f "$run_dir/$ipa_name" "$output/$ipa_name"
printf 'Unsigned IPA: %s\n' "$output/$ipa_name"
