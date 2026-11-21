#!/bin/sh
set -eu

state="$HOME/ProbablyStolenBuild"
selected=${1:-none}
shift

locate_logs() {
    result="$state/results/$1"
    status=queued
    build_log= unity_log= xcode_log= ipa=0

    if [ -f "$result/status" ]; then
        status=$(cat "$result/status")
        case "$status" in succeeded|failed) ;; *) status=unknown ;; esac
        build_log="$result/build.log"
        unity_log="$result/unity.log"
        xcode_log="$result/xcode.log"
        if [ -s "$result/ProbablyStolen-unsigned.ipa" ]; then ipa=1; fi
        return
    fi

    for attempt in "$state/jobs/$1".*; do
        [ -f "$attempt/build.log" ] || continue
        status=starting
        build_log="$attempt/build.log"
        unity_log= xcode_log=
        for run in "$attempt"/build/run.*; do
            if [ -f "$run/unity.log" ]; then unity_log="$run/unity.log"; status=unity; fi
            if [ -f "$run/xcode.log" ]; then xcode_log="$run/xcode.log"; status=xcode; fi
        done
    done
}

emit_log() {
    name=$1 file=$2 offset=$3
    [ -f "$file" ] || return 0
    size=$(wc -c < "$file")
    if [ "$offset" -gt "$size" ]; then offset=0; fi
    printf 'L|%s|%s|' "$name" "$offset"
    if [ "$offset" -lt "$size" ]; then
        tail -c "+$((offset + 1))" "$file" | head -c 32768 | base64 | tr -d '\r\n'
    fi
    printf '\n'
}

refs=$(git --git-dir="$state/source.git" for-each-ref --count=40 --sort=-refname \
    --format='%(refname)' refs/ios-builds/)
for ref in $refs; do
    job=${ref##*/}
    locate_logs "$job"
    printf 'J|%s|%s|%s\n' "$job" "$status" "$ipa"
done

if [ "$selected" != none ]; then
    locate_logs "$selected"
    emit_log build "$build_log" "$1"
    emit_log unity "$unity_log" "$2"
    emit_log xcode "$xcode_log" "$3"
fi
