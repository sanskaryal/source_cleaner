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

printf 'Pi Home File Cleaner\n'
printf 'Search location: %s (including subfolders)\n\n' "$HOME_DIR"
printf 'Choose files to find:\n'
printf '  1) *.*       Files whose names contain a dot\n'
printf '  2) *.s       Assembly source files\n'
printf '  3) *.o *.s   Object and assembly source files\n'
printf '  4) *.o *.s and executable files with no dot in the name\n'
printf '  5) Custom filename patterns (space-separated, e.g. *.s *.pdf)\n'
printf '  q) Quit\n'
printf '\nChoice: '
IFS= read -r choice || exit 1

case "$choice" in
    1)
        patterns=('*.*')
        ;;
    2)
        patterns=('*.s')
        ;;
    3|4)
        patterns=('*.o' '*.s')
        ;;
    5)
        printf 'Patterns (space-separated): '
        IFS= read -r pattern_line || exit 1
        read -r -a patterns <<< "$pattern_line"
        if ((${#patterns[@]} == 0)); then
            printf 'No patterns entered; nothing to do.\n'
            exit 0
        fi
        for pattern in "${patterns[@]}"; do
            if [[ "$pattern" == */* || "$pattern" == '.' || "$pattern" == '..' ]]; then
                printf 'Error: use filename patterns without directory paths.\n' >&2
                exit 1
            fi
        done
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

matches=()

add_match() {
    local candidate=$1
    local existing

    for existing in "${matches[@]}"; do
        [[ "$existing" == "$candidate" ]] && return
    done
    matches+=("$candidate")
}

collect_pattern() {
    local pattern=$1
    local candidate

    if ! find "$HOME_DIR" -type f -name "$pattern" -print0 > "$matches_file"; then
        printf 'Error: search failed for pattern %q.\n' "$pattern" >&2
        return 1
    fi

    while IFS= read -r -d '' candidate; do
        add_match "$candidate"
    done < "$matches_file"
}

for pattern in "${patterns[@]}"; do
    collect_pattern "$pattern" || exit 1
done

if [[ "$choice" == 4 ]]; then
    if ! find "$HOME_DIR" -type f ! -name '*.*' \
        -exec sh -c 'test -x "$1"' sh {} \; -print0 > "$matches_file"; then
        printf 'Error: search for executable files failed.\n' >&2
        exit 1
    fi

    while IFS= read -r -d '' candidate; do
        add_match "$candidate"
    done < "$matches_file"
fi

if ((${#matches[@]} == 0)); then
    printf '\nNo matching files found. Nothing changed.\n'
    exit 0
fi

printf '\nFound %d file(s):\n' "${#matches[@]}"
for candidate in "${matches[@]}"; do
    printf '  %q\n' "$candidate"
done

printf '\nOnly these regular files will be removed. Directories and symlinks are not removed.\n'
printf 'Type DELETE to permanently remove these files, or anything else to cancel: '
IFS= read -r confirmation || exit 1

if [[ "$confirmation" != 'DELETE' ]]; then
    printf 'Cancelled. Nothing changed.\n'
    exit 0
fi

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

printf '\nRemoved %d file(s).' "$deleted"
if ((failed > 0)); then
    printf ' Failed to remove %d file(s).\n' "$failed"
    exit 1
fi
printf '\n'
