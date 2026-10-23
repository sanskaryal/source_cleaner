#!/usr/bin/env bash

if [[ -z "${HOME:-}" || ! -d "$HOME" ]]; then
    printf 'Error: HOME is not set to an existing directory.\n' >&2
    exit 1
fi

HOME_DIR=$(cd -P -- "$HOME" && pwd) || {
    printf 'Error: could not resolve the home directory.\n' >&2
    exit 1
}

if [[ "$HOME_DIR" == "/" ]]; then
    printf 'Error: refusing to clean the filesystem root.\n' >&2
    exit 1
fi

printf 'Deleting .s, .o, and executable files without extensions under %s\n' "$HOME_DIR"

find "$HOME_DIR" -type f \
    \( -name '*.s' -o -name '*.o' -o \( ! -name '*.*' -exec test -x {} \; \) \) \
    -print -delete
