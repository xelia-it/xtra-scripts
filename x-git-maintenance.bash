#!/bin/bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Automatic mainteinance for Git repository
# ------------------------------------------------------------------------------

set -e

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "Git Repo Maintenance"

# ------------------------------------------------------------------------------
# Settings

project_folder=$(pwd)
clean_unktracked=n

# ------------------------------------------------------------------------------
# Functions

usage() {
    echo "Usage: $(basename $0) [-p <project>] [-c] [-h | -?]"
    echo
    echo "Where:"
    echo "  -p <project>  - project root folder"
    echo "  -c            - clean untracked files"
    echo "  -h | -?       - shows this help screen"
}

print_stats() {
    echo
    echo -e "Git repo $color_white$1$color_reset maintenance:"
    echo
    git count-objects -vH
}

do_git_maintenance() {
    echo -e "$color_white$icon_arrow_right$color_reset Current directory: $color_white$(pwd)$color_reset"

    # Goto project folder
    pushd . &> /dev/null
    cd $project_folder

    # Check if directory is a git repository
    if [ ! -d ".git" ]; then
        x_fail "Not a Git repo"
        exit 1
    fi

    print_stats "before"

    # Garbage collection with immediate pruning and max compression
    echo
    echo -e "$color_white$icon_arrow_right$color_reset Garbage collection..."
    echo
    git gc --prune=now --aggressive

    # Removes invalid remote references
    echo
    echo -e "$color_white$icon_arrow_right$color_reset Cleanup remote references..."
    echo
    git remote prune origin

    # Verify repository integrity
    echo
    echo -e "$color_white$icon_arrow_right$color_reset Integrity check..."
    echo
    git fsck --full

    # Ask confirmation before removing untracked files
    echo
    echo -e -n "$color_white$icon_arrow_right$color_reset Cleanup untracked files..."
    if [[ "$clean_unktracked" == "y" ]]; then
        echo
        git clean -fd
    else
        echo -e "$color_blue Skipped$color_reset"
    fi

    # Delete unreferenced objects
    echo
    echo -e "$color_white$icon_arrow_right$color_reset Clean unreferenced objects..."
    echo
    git prune -v

    print_stats "after"

    echo
    echo -e "$icon_check_mark Complete"

    popd &> /dev/null
}

# ------------------------------------------------------------------------------
# Main

while getopts "hp:c" arg ; do
    case $arg in
        p)
            op="p"
            project_folder=${OPTARG}
            ;;
        c)
            clean_unktracked_files="y"
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
