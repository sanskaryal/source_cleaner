#!/usr/bin/env bash

if [[ "$(uname -s)" != 'Linux' ]]; then
    printf 'Error: this test only runs on Linux.\n' >&2
    exit 1
fi

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    printf 'Error: run this test as your normal user, not with sudo.\n' >&2
    exit 1
fi

SCRIPT_DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || {
    printf 'Error: could not resolve the script directory.\n' >&2
    exit 1
}

source_file="$SCRIPT_DIR/BlinkingLED_StudentExample.s"
if [[ ! -f "$source_file" ]]; then
    printf 'Error: assembly source not found: %s\n' "$source_file" >&2
    exit 1
fi

for command_name in as gcc sudo; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Error: required command not found: %s\n' "$command_name" >&2
        exit 1
    fi
done

build_dir=$(mktemp -d "${TMPDIR:-/tmp}/led-test.XXXXXX") || {
    printf 'Error: could not create temporary build directory.\n' >&2
    exit 1
}
trap 'rm -rf -- "$build_dir"' EXIT

object_file="$build_dir/BlinkingLED_StudentExample.o"
executable="$build_dir/BlinkingLED_StudentExample"

printf 'Assembling %s...\n' "$source_file"
as -o "$object_file" "$source_file" || {
    printf 'Error: assembly failed.\n' >&2
    exit 1
}

printf 'Linking with WiringPi...\n'
gcc -o "$executable" "$object_file" -lwiringPi || {
    printf 'Error: linking failed. Check that WiringPi is installed and compatible with this Pi OS.\n' >&2
    exit 1
}

printf 'Running LED test with sudo. Connect the LEDs to the GPIO pins used by the example.\n'
sudo "$executable"
run_status=$?

if ((run_status != 0)); then
    printf 'Error: LED test exited with status %d.\n' "$run_status" >&2
    exit "$run_status"
fi

printf 'LED test finished. Temporary object and executable files will be removed.\n'
