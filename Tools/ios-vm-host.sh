#!/bin/bash
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo"

ssh_options=(-o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=yes)
export GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=yes'
if [[ -f "$HOME/.ssh/probablystolen_vm_ed25519" ]]; then
    ssh_options+=(-i "$HOME/.ssh/probablystolen_vm_ed25519" -o IdentitiesOnly=yes)
    GIT_SSH_COMMAND+=' -i "$HOME/.ssh/probablystolen_vm_ed25519" -o IdentitiesOnly=yes'
fi

case "${1:-}" in
    install)
        remote=${2:?Usage: bash Tools/ios-vm-host.sh install USER@MAC_ADDRESS}
        if [[ ! $remote =~ ^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$ || $remote == -* ]]; then
            echo 'Expected an SSH destination in USER@MAC_ADDRESS format.' >&2
            exit 2
        fi
        if git config --get core.hooksPath >/dev/null; then
            echo 'This repository uses a custom Git hooks path. Add the queue command to its existing post-commit hook.' >&2
            exit 1
        fi
        hook=$(git rev-parse --git-path hooks/post-commit)
        hook_contents='#!/bin/sh
bash Tools/ios-vm-host.sh queue || echo "iOS build was not queued. Retry with: bash Tools/ios-vm-host.sh queue" >&2'
        if [[ -e "$hook" ]] && ! cmp -s "$hook" <(printf '%s\n' "$hook_contents"); then
            printf 'Existing Git hook preserved at %s. Add: bash Tools/ios-vm-host.sh queue\n' "$hook" >&2
            exit 1
        fi

        git config --local port.iosVmHost "$remote"
        mkdir -p "$(dirname "$hook")"
        printf '%s\n' "$hook_contents" > "$hook"
        chmod +x "$hook"
        printf 'iOS build queue installed for %s\n' "$remote"
        ;;
    queue)
        commit=$(git rev-parse HEAD)
        for file in Tools/build-ios-local.sh UnityProject/Assets/Editor/PortIosExport.cs; do
            if ! git cat-file -e "$commit:$file"; then
                printf 'Commit %s is missing %s. Commit the local build files first.\n' "$commit" "$file" >&2
                exit 1
            fi
        done
        job="$(date -u +%Y%m%dT%H%M%SZ)-$commit-$RANDOM$$"
        git update-ref "refs/ios-builds/$job" "$commit"
        printf 'Queued iOS build %s\n' "$job"
        ;;
    sync)
        remote=$(git config --local --get port.iosVmHost)
        results="$repo/build/vm-results"
        mkdir -p "$results"
        refs=$(git for-each-ref --format='%(refname)' refs/ios-builds/)
        requests=()
        while IFS= read -r ref; do
            if [[ -n "$ref" ]]; then requests+=("$ref:$ref"); fi
        done <<< "$refs"
        if [[ ${#requests[@]} -gt 0 ]]; then
            git push --atomic --quiet "$remote:ProbablyStolenBuild/source.git" "${requests[@]}"
            while IFS= read -r ref; do git update-ref -d "$ref"; done <<< "$refs"
        fi

        completed=$(ssh "${ssh_options[@]}" "$remote" 'ls -1 ProbablyStolenBuild/results')
        while IFS= read -r job; do
            [[ $job =~ ^[0-9]{8}T[0-9]{6}Z-[0-9a-f]{40}-[0-9]+$ ]] || continue
            [[ ! -e "$results/$job" ]] || continue
            staging=$(mktemp -d "$results/.incoming.XXXXXXXX")
            ssh "${ssh_options[@]}" "$remote" "tar -C ProbablyStolenBuild/results -cf - $job" |
                tar -xf - -C "$staging"
            [[ -f "$staging/$job/status" && -f "$staging/$job/build.log" ]]
            mv -T "$staging/$job" "$results/$job"
            rmdir "$staging"
            printf 'Downloaded iOS build result %s\n' "$job"
        done <<< "$completed"
        ;;
    *)
        echo 'Usage: bash Tools/ios-vm-host.sh install USER@MAC_ADDRESS | queue | sync' >&2
        exit 2
        ;;
esac
