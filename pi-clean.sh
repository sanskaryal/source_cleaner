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

printf 'Project Cleaner\n'
printf 'Search location: %s (hidden directories will be skipped)\n\n' "$HOME_DIR"
printf 'Choose what to clean:\n'
printf '  1) *.s, *.o, and executable files with no extension\n'
printf '  2) *.* files and all executable files\n'
printf '  q) Quit\n'
printf '\nChoice: '
IFS= read -r choice || exit 1

case "$choice" in
    1)
        find_expression=( \( -name '*.s' -o -name '*.o' -o \( ! -name '*.*' -exec test -x {} \; \) \) )
        ;;
    2)
        find_expression=( \( -name '*.*' -o -exec test -x {} \; \) )
        ;;
    q|Q)
        printf 'Nothing changed.\n'
        exit 0
        ;;
    *)
        printf 'Invalid choice; nothing changed.\n' >&2
        exit 1
        ;;
esac

matches_file=$(mktemp "${TMPDIR:-/tmp}/pi-clean.XXXXXX") || {
    printf 'Error: could not create a temporary file for the search.\n' >&2
    exit 1
}
trap 'rm -f -- "$matches_file"' EXIT

if ! find "$HOME_DIR" -type d -name '.*' -prune -o -type f "${find_expression[@]}" -print0 > "$matches_file"; then
    printf 'Error: file search failed.\n' >&2
    exit 1
fi

matches=()
while IFS= read -r -d '' candidate; do
    matches+=("$candidate")
done < "$matches_file"

if ((${#matches[@]} == 0)); then
    printf '\nNo matching files found.\n'
else
    printf '\nFound %d file(s):\n' "${#matches[@]}"
    for candidate in "${matches[@]}"; do
        printf '  %q\n' "$candidate"
    done

    printf '\nAre you sure you want to DELETE these %d file(s)? [y/N] ' "${#matches[@]}"
    IFS= read -r confirmation || confirmation=''
    case "$confirmation" in
        y|Y|yes|YES|Yes)
            deleted=0
            failed=0
            for candidate in "${matches[@]}"; do
                if rm -f -- "$candidate"; then
                    ((deleted += 1))
                else
                    printf 'Could not remove %q\n' "$candidate" >&2
                    ((failed += 1))
                fi
            done
            printf 'Removed %d file(s).' "$deleted"
            if ((failed > 0)); then
                printf ' Failed to remove %d file(s).\n' "$failed"
            else
                printf '\n'
            fi
            ;;
        *)
            printf 'File cleanup cancelled.\n'
            ;;
    esac
fi

TRASH_DIR="$HOME_DIR/.local/share/Trash"
printf '\nDo you want to clean the Trash too? [y/N] '
IFS= read -r clean_trash || clean_trash=''
case "$clean_trash" in
    y|Y|yes|YES|Yes)
        if [[ -L "$TRASH_DIR" ]]; then
            printf 'Error: Trash path is a symbolic link; refusing to clean it.\n' >&2
            exit 1
        elif [[ -d "$TRASH_DIR" ]]; then
            if find "$TRASH_DIR" -mindepth 1 -depth -exec rm -rf -- {} +; then
                printf 'Trash emptied.\n'
            else
                printf 'Error: could not completely empty Trash.\n' >&2
                exit 1
            fi
        else
            printf 'No standard Linux Trash directory found.\n'
        fi
        ;;
    *)
        printf 'Trash left untouched.\n'
        ;;
esac
