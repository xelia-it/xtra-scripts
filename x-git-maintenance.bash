#!/bin/bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Cleanup system
# ------------------------------------------------------------------------------

set -e

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "Git Repo Maintenance"

# ------------------------------------------------------------------------------
# Settings

clean_unktracked=n

# ------------------------------------------------------------------------------
# Functions

usage() {
    echo "Usage: $(basename $0) [-M] [-h | -?]"
    echo
    echo "Where:"
    echo "  -c           - clean untracked files"
    echo "  -h | -?      - shows this help screen"
}

do_git_maintenance() {
    echo -e "$color_white$icon_arrow_right_bar$color_reset Current directory: $color_white$(pwd)$color_reset"

    # Controlla se la directory è un repository Git
    if [ ! -d ".git" ]; then
        x_fail "Not a Git repo"
        exit 1
    fi

    echo -e "$color_white$icon_arrow_right_bar$color_reset Garbage collection..."
    git gc --prune=now --aggressive

    echo -e "$color_white$icon_arrow_right_bar$color_reset Cleanup remote references..."
    git remote prune origin

    echo -e "$color_white$icon_arrow_right_bar$color_reset Integrity check..."
    git fsck --full

    echo -e -n "$color_white$icon_arrow_right_bar$color_reset Cleanup untracked files..."
    if [[ "$clean_unktracked" == "y" ]]; then
        echo
        git clean -fd
    else
        echo "Skipped"
    fi

    echo -e "$color_white$icon_arrow_right_bar$color_reset Clean unreferenced objects..."
    git prune -v

    echo -e "$icon_check_mark Complete"
}

# ------------------------------------------------------------------------------
# Main

while getopts "hMv" arg ; do
    case $arg in
        c)
            clean_unktracked=y
            ;;
        h | ?)
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

do_git_maintenance
