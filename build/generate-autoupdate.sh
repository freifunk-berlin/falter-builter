#!/usr/bin/env bash

# Usage: generate-autoupdate.sh <version> <out-dir>

function usage() {
    exit 1
}

set -e
set -o pipefail
# set -x

[ -n "$1" ] && fversion="$1" || usage >&2
[ -n "$2" ] && outdir="$2" || outdir="./out"

(
    echo '{"falter-version": "'"$fversion"'"}'

    # .devices
    cat "$outdir/$fversion"/*/*/*/profiles.json | jq -s '.[] as $t | $t.profiles | keys[] as $p | $t.profiles[$p] | .supported_devices | unique | .[] | select(contains(",")) | {(.): {target: $t.target, profile: $p}}' | jq -S -s 'add | {devices: (.)}'

    # .profiles[].tunneldigger
    for f in "$outdir/$fversion"/tunneldigger/*/*/profiles.json; do
        target="$(cat "$f" | jq -r .target)"
        shasum="$(sha256sum "$f" | cut -d' ' -f1)"
        url="/unstable/$fversion/tunneldigger/$target/profiles.json"
        echo '{"profiles": {"'"$target"'": {"tunneldigger": {"url": "'"$url"'", "sha256sum": "'"$shasum"'"}}}}'
    done

    # .profiles[].notunnel
    for f in "$outdir/$fversion"/notunnel/*/*/profiles.json; do
        target="$(cat "$f" | jq -r .target)"
        shasum="$(sha256sum "$f" | cut -d' ' -f1)"
        url="/unstable/$fversion/notunnel/$target/profiles.json"
        echo '{"profiles": {"'"$target"'": {"notunnel": {"url": "'"$url"'", "sha256sum": "'"$shasum"'"}}}}'
    done

    # .target[][].tunneldigger
    cat "$outdir/$fversion"/tunneldigger/*/*/profiles.json | jq -r '.target as $t | .profiles | keys[] as $p | .[$p].images[] | select(.type == "sysupgrade") | {target: {($t): {($p): {notunnel: .sha256}}}}'

    # .target[][].notunnel
    cat "$outdir/$fversion"/notunnel/*/*/profiles.json | jq -r '.target as $t | .profiles | keys[] as $p | .[$p].images[] | select(.type == "sysupgrade") | {target: {($t): {($p): {tunneldigger: .sha256}}}}'

) | jq -s 'reduce .[] as $o ({}; . * $o)'
