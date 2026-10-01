#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xtra Scripts
#
# System cleanup
# ------------------------------------------------------------------------------

set -e

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SOURCE_DIR/_colors.bash"
source "$SOURCE_DIR/_commons.bash"
source "$SOURCE_DIR/_settings.bash"

x_print_title "System cleanup"

force=false

# ------------------------------------------------------------------------------
# Functions

# print_section($message)
#
# Print a section subtitle with proper colors and extra line separator
#
function print_section() {
    echo -e "${color_white}${icon_arrow_right}${color_reset}  $1"
    echo
}

function usage() {
    echo "Usage: $(basename "$0") [-f] [-h | -?]"
    echo
    echo "Where:"
    echo "  -f           - skip confirmation prompt"
    echo "  -h | -?      - shows this help screen"
}

function confirm_cleanup() {
    if [ "$force" = true ]; then
        return 0
    fi

    echo
    read -r -p "This will clear package caches, Docker data, npm/pip cache, and logs. Continue? [y/N]: " response
    case "$response" in
        y|Y|yes|YES)
            return 0
            ;;
        *)
            echo "Cleanup cancelled."
            exit 0
            ;;
    esac
}

function do_cleanup() {
    confirm_cleanup
    x_ensure_user_is_root

    print_section "Clean apt cache..."

    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
    sudo apt-get clean -y
    echo

    print_section "Remove cache and lock file cache no more used..."

    sudo rm -rf /var/lib/apt/lists/*
    sudo rm -rf /var/cache/apt/archives/*
    sudo rm -rf /var/cache/*

    print_section "Cleanup old logs..."

    sudo journalctl --vacuum-time=7d
    sudo journalctl --rotate
    sudo journalctl --vacuum-size=100M
    echo

    print_section "Cleanup thumbnails..."

    rm -rf ~/.cache/thumbnails/*

    print_section "Cleanup Docker (if present)..."

    if command -v docker >/dev/null 2>&1; then
        docker system prune -af
        echo
    fi

    print_section "Cleanup pip cache..."

    rm -rf ~/.cache/pip

    print_section "Cleanup npm cache (if present)..."

    if command -v npm >/dev/null 2>&1; then
        npm cache clean --force
    fi

    print_section "Cleanup with flatpak (if present)..."

    if command -v flatpak >/dev/null 2>&1; then
        flatpak uninstall --unused -y
    fi

    echo -e "${color_green}${icon_check_mark}${color_reset}  Complete"
}

# ------------------------------------------------------------------------------
# Main

function main() {
    while getopts "hf" arg ; do
        case $arg in
            f)
                force=true
                ;;
            h | \?)
                usage
                exit 0
                ;;
            *)
                usage
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    do_cleanup
}

main "$@"
