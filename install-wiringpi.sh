#!/usr/bin/env bash

if [[ "$(uname -s)" != 'Linux' ]]; then
    printf 'Error: this installer only runs on Linux.\n' >&2
    exit 1
fi

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    printf 'Error: run this installer as your normal user, not with sudo.\n' >&2
    exit 1
fi

for command_name in sudo apt-get dpkg; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Error: required command not found: %s\n' "$command_name" >&2
        exit 1
    fi
done

printf 'Updating package lists and installing build tools...\n'
sudo apt-get update || exit 1
sudo apt-get install -y git build-essential || exit 1

if ! command -v git >/dev/null 2>&1; then
    printf 'Error: git is still unavailable after installation.\n' >&2
    exit 1
fi

build_dir=$(mktemp -d "${TMPDIR:-/tmp}/wiringpi-build.XXXXXX") || {
    printf 'Error: could not create temporary build directory.\n' >&2
    exit 1
}

(
    trap 'rm -rf -- "$build_dir"' EXIT
    repo_dir="$build_dir/WiringPi"

    printf 'Cloning WiringPi into a temporary directory...\n'
    GIT_TERMINAL_PROMPT=0 git clone https://github.com/WiringPi/WiringPi.git "$repo_dir" || {
        printf 'Error: could not clone WiringPi. Check network access and GitHub URL configuration.\n' >&2
        exit 1
    }

    printf 'Building Debian package...\n'
    (
        cd "$repo_dir" &&
        ./build debian
    ) || {
        printf 'Error: WiringPi package build failed.\n' >&2
        exit 1
    }

    shopt -s nullglob
    deb_packages=("$repo_dir"/debian-template/wiringpi*.deb)
    shopt -u nullglob
    if ((${#deb_packages[@]} == 0)); then
        printf 'Error: build finished but no wiringpi*.deb package was found.\n' >&2
        exit 1
    fi

    printf 'Installing WiringPi package(s)...\n'
    if ! sudo dpkg -i "${deb_packages[@]}"; then
        printf 'Resolving package dependencies and retrying...\n'
        sudo apt-get --fix-broken install -y || exit 1
        sudo dpkg -i "${deb_packages[@]}" || exit 1
    fi

    if ! command -v gpio >/dev/null 2>&1; then
        printf 'Error: package installation completed, but the gpio command was not found.\n' >&2
        exit 1
    fi

    printf 'WiringPi installed successfully. The temporary source checkout will be removed.\n'
)
