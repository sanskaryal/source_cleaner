#!/usr/bin/env bash

if [[ "$(uname -s)" != 'Linux' ]]; then
    printf 'Error: this script only runs on Linux; refusing to clean this home directory.\n' >&2
    exit 1
fi

if [[ -z "${HOME:-}" || ! -d "$HOME" ]]; then
    printf 'Error: HOME is not set to an existing directory.\n' >&2
    exit 1
fi

HOME_DIR=$(cd -P -- "$HOME" && pwd) || {
    printf 'Error: could not resolve the home directory.\n' >&2
    exit 1
}

SCRIPT_DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || {
    printf 'Error: could not resolve the script directory.\n' >&2
    exit 1
}

case "$HOME_DIR" in
    /home/*)
        ;;
    *)
        printf 'Error: refusing to clean a home directory outside /home/.\n' >&2
        exit 1
        ;;
esac

standard_folders=(Desktop Documents Downloads Music Pictures Public Templates Videos)
trash_dir="$HOME_DIR/.local/share/Trash"
shopt -s dotglob nullglob

remove_children() {
    local directory=$1
    local preserve_hidden=${2:-false}
    local child
    local name
    local failed=0

    for child in "$directory"/*; do
        name=${child##*/}
        if is_script_directory_or_parent "$child"; then
            printf 'Preserving script directory: %q\n' "$child"
            continue
        fi
        if [[ "$preserve_hidden" == true && "$name" == .* ]]; then
            continue
        fi
        if ! rm -rf -- "$child"; then
            printf 'Error: could not remove %q\n' "$child" >&2
            failed=1
        fi
    done
    return "$failed"
}

is_script_directory_or_parent() {
    local candidate=$1
    [[ "$SCRIPT_DIR" == "$candidate" || "$SCRIPT_DIR" == "$candidate/"* ]]
}

printf 'Cleaning non-hidden contents of %s without confirmation.\n' "$HOME_DIR"
printf 'Non-standard visible folders will be removed completely.\n'
printf 'Hidden items are preserved except contents of non-standard folders and Trash.\n'
printf 'The directory containing this script and its contents will be preserved.\n'

if [[ -L "$trash_dir" ]]; then
    printf 'Error: Trash path is a symbolic link; refusing to clean it.\n' >&2
    exit 1
fi

if [[ -d "$trash_dir" ]]; then
    printf 'Emptying Trash: %s\n' "$trash_dir"
    if ! remove_children "$trash_dir"; then
        printf 'Error: could not completely empty Trash.\n' >&2
        exit 1
    fi
fi

failed=0
for entry in "$HOME_DIR"/*; do
    name=${entry##*/}

    if [[ "$name" == .* ]]; then
        continue
    fi
    if is_script_directory_or_parent "$entry"; then
        printf 'Preserving script directory: %q\n' "$entry"
        continue
    fi

    is_standard=false
    for folder in "${standard_folders[@]}"; do
        if [[ "$name" == "$folder" ]]; then
            is_standard=true
            break
        fi
    done

    if [[ "$is_standard" == true ]]; then
        if [[ -L "$entry" ]]; then
            printf 'Error: standard folder is a symbolic link; leaving it untouched: %q\n' "$entry" >&2
            failed=1
        elif [[ -d "$entry" ]]; then
            printf 'Cleaning %s\n' "$entry"
            if ! remove_children "$entry" true; then
                failed=1
            fi
        else
            printf 'Removing non-directory at standard folder path: %q\n' "$entry"
            if ! rm -f -- "$entry"; then
                printf 'Error: could not remove %q\n' "$entry" >&2
                failed=1
            fi
        fi
    else
        printf 'Removing non-standard item: %q\n' "$entry"
        if ! rm -rf -- "$entry"; then
            printf 'Error: could not remove %q\n' "$entry" >&2
            failed=1
        fi
    fi
done

if ((failed != 0)); then
    printf 'Error: cleanup was incomplete; standard folders were not recreated.\n' >&2
    exit 1
fi

for folder in "${standard_folders[@]}"; do
    if ! mkdir -p -- "$HOME_DIR/$folder"; then
        printf 'Error: could not create %s.\n' "$HOME_DIR/$folder" >&2
        exit 1
    fi
done

printf 'Cleanup complete. Standard home folders are ready.\n'
