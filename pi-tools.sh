#!/usr/bin/env bash

if [[ "$(uname -s)" != 'Linux' ]]; then
    printf 'Error: this tool only runs on Linux.\n' >&2
    exit 1
fi

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    printf 'Error: run this tool as your normal user, not with sudo.\n' >&2
    printf 'The installer will request sudo only for system package operations.\n' >&2
    exit 1
fi

SCRIPT_DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || {
    printf 'Error: could not resolve the script directory.\n' >&2
    exit 1
}

printf 'Pi Tools\n'
printf '  1) Clean the Pi home directory\n'
printf '  2) Install WiringPi\n'
printf '  3) Test the blinking LED assembly example\n'
printf '  q) Quit\n'
printf '\nChoice: '
IFS= read -r choice || exit 1

case "$choice" in
    1)
        if [[ ! -f "$SCRIPT_DIR/pi-clean.sh" ]]; then
            printf 'Error: pi-clean.sh was not found beside this script.\n' >&2
            exit 1
        fi
        bash "$SCRIPT_DIR/pi-clean.sh"
        ;;
    2)
        if [[ ! -f "$SCRIPT_DIR/install-wiringpi.sh" ]]; then
            printf 'Error: install-wiringpi.sh was not found beside this script.\n' >&2
            exit 1
        fi
        bash "$SCRIPT_DIR/install-wiringpi.sh"
        ;;
    3)
        if [[ ! -f "$SCRIPT_DIR/test_led.sh" ]]; then
            printf 'Error: test_led.sh was not found beside this script.\n' >&2
            exit 1
        fi
        bash "$SCRIPT_DIR/test_led.sh"
        ;;
    q|Q)
        printf 'Nothing changed.\n'
        ;;
    *)
        printf 'Invalid choice; nothing changed.\n' >&2
        exit 1
        ;;
esac
