#!/bin/bash
set -euo pipefail

state="$HOME/ProbablyStolenBuild"
label=com.probablystolen.ios-build

if [[ ${1:-} == --install ]]; then
    if [[ $# -eq 2 ]]; then
        IFS= read -r public_key < "$2"
        if [[ ! $public_key =~ ^ssh-ed25519\ [A-Za-z0-9+/=]+(\ .*)?$ ]]; then
            echo 'Expected an SSH Ed25519 public key.' >&2
            exit 1
        fi
        public_key="restrict $public_key"
        mkdir -p -m 700 "$HOME/.ssh"
        authorized_keys="$HOME/.ssh/authorized_keys"
        touch "$authorized_keys"
        chmod 600 "$authorized_keys"
        if ! grep -Fqx -- "$public_key" "$authorized_keys"; then
            printf '\n%s\n' "$public_key" >> "$authorized_keys"
        fi
    fi
    mkdir -p "$state/results" "$HOME/Library/LaunchAgents"
    if [[ ! -d "$state/source.git" ]]; then git init --quiet --bare "$state/source.git"; fi
    if [[ ! ${BASH_SOURCE[0]} -ef "$state/worker.sh" ]]; then
        cp "${BASH_SOURCE[0]}" "$state/worker.sh"
    fi
    plist="$HOME/Library/LaunchAgents/$label.plist"
    cat > "$plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>com.probablystolen.ios-build</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>exec /bin/bash "$HOME/ProbablyStolenBuild/worker.sh" --poll &gt;&gt; "$HOME/ProbablyStolenBuild/runner.log" 2&gt;&amp;1</string>
    </array>
    <key>RunAtLoad</key><true/>
    <key>StartInterval</key><integer>20</integer>
</dict>
</plist>
PLIST
    plutil -lint "$plist"
    domain="gui/$(id -u)"
    if launchctl print "$domain/$label" >/dev/null 2>&1; then
        launchctl bootout "$domain/$label"
    fi
    launchctl bootstrap "$domain" "$plist"
    echo 'iOS build worker loaded.'
    exit 0
fi

if [[ ${1:-} != --poll ]]; then
    echo 'Usage: bash worker.sh --install | --poll' >&2
    exit 2
fi

source_repo="$state/source.git"
refs=$(git --git-dir="$source_repo" for-each-ref --format='%(refname)' refs/ios-builds/)
checkout="$state/checkout"
mkdir -p "$state/jobs"
if [[ ! -d "$checkout/.git" ]]; then
    git init --quiet "$checkout"
fi

build_job() (
    set -e
    cd "$checkout"
    git fetch --quiet --no-tags "$source_repo" "$ref" || exit "$?"
    actual=$(git rev-parse FETCH_HEAD) || exit "$?"
    if [[ "$actual" != "$commit" ]]; then
        printf 'Expected %s, fetched %s\n' "$commit" "$actual" >&2
        exit 1
    fi
    # This checkout belongs to the worker. Unity can change tracked settings during import.
    git -c advice.detachedHead=false checkout --quiet --force --detach "$commit" || exit "$?"
    PORT_IOS_OUTPUT_DIR="$attempt/build" /bin/bash Tools/build-ios-local.sh
)

while IFS= read -r ref; do
    job=${ref##*/}
    [[ $job =~ ^[0-9]{8}T[0-9]{6}Z-([0-9a-f]{40})-[0-9]+$ ]] || continue
    commit=${BASH_REMATCH[1]}
    [[ ! -e "$state/results/$job" ]] || continue

    attempt=$(mktemp -d "$state/jobs/$job.XXXXXXXX")
    staging=$(mktemp -d "$state/results/.pending.XXXXXXXX")
    status=failed
    {
        printf 'Commit: %s\n' "$commit"
        if build_job && [[ -s "$attempt/build/ProbablyStolen-unsigned.ipa" ]]; then
            status=succeeded
        fi
    } > "$attempt/build.log" 2>&1

    cp "$attempt/build.log" "$staging/"
    shopt -s nullglob
    for log in "$attempt"/build/run.*/{unity,xcode}.log; do
        cp "$log" "$staging/"
    done
    if [[ $status == succeeded ]]; then
        cp "$attempt/build/ProbablyStolen-unsigned.ipa" "$staging/"
    fi
    printf '%s\n' "$commit" > "$staging/commit"
    printf '%s\n' "$status" > "$staging/status"
    mv "$staging" "$state/results/$job"
    printf '%s %s\n' "$job" "$status"
done <<< "$refs"
