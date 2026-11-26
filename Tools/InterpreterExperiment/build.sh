#!/bin/bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
unity=/Applications/Unity/Hub/Editor/2021.3.45f2/Unity.app/Contents/MacOS/Unity
stage_log_dir=${PORT_IOS_STAGE_LOG_DIR:-$root}
mkdir -p "$stage_log_dir"
stage_log_dir=$(cd "$stage_log_dir" && pwd)
cd "$root/UnityProject"
for method in VerifyLifecycle Generate CopyMetadata; do
    echo "Unity interpreter step: $method"
    log="$stage_log_dir/$method.log"
    "$unity" -batchmode -quit -nographics -projectPath "$PWD" -buildTarget iOS -executeMethod "PortInterpreterBuild.$method" -logFile "$log" || { tail -n 50 "$log"; exit 1; }
done
exec /bin/bash "$root/Tools/build-ios-local.sh"
