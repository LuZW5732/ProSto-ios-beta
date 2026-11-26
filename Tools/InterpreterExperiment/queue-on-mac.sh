#!/bin/bash
set -euo pipefail

state="$HOME/ProbablyStolenBuild"
project=$(cd -P "${1:?Pass the prepared interpreter project directory}" && pwd)
[[ "$project" == "$state/experiments/"* && -f "$project/Tools/build.sh" ]]
grep -Fxq -- '-define:PROSTO_INTERP' "$project/UnityProject/Assets/csc.rsp"
test -s "$project/UnityProject/WorkshopReference/ShutterEvents/ShutterEvents.dll" ||
    test -s "$project/UnityProject/WorkshopReference/ShutterEvents.dll"
commit=$(git --git-dir="$state/source.git" rev-parse --verify "${2:?Pass the base game commit}^{commit}")
job="$(date -u +%Y%m%dT%H%M%SZ)-$commit-$RANDOM$$"
mkdir -p "$state/experiments/requests"
ln -s "$project" "$state/experiments/requests/$job"
git --git-dir="$state/source.git" update-ref "refs/ios-builds/$job" "$commit" ''
printf 'Queued local no-JIT build: %s\n' "$job"
