#!/bin/bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Automatic mainteinance for Git repositoy
# ------------------------------------------------------------------------------

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "Git Repo Mainteinance"

# ------------------------------------------------------------------------------
# Settings

project_folder=$(pwd)
clean_unktracked_files="n"

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

git_mainteinance() {
    pushd . &> /dev/null
    echo -e "Current folder: $color_white$project_folder$color_reset"
    cd $project_folder

    if [ ! -d ".git" ]; then
        echo "Error: not a git repository"
        popd &> /dev/null
        exit 1
    fi

    echo
    echo -e "Git repo ${color_white}before${color_reset} maintainance:"
    git count-objects -vH

    # Garbage collection with immediate pruning and max compression
    echo
    echo "Garbage collection ..."
    git gc --prune=now --aggressive

    # Removes invalid remote references
    echo
    echo "Cleanup remote references ..."
    git remote prune origin

    # Verify repository integrity
    echo
    echo "Verify repository integrity ..."
    git fsck --full

    # Ask confirmation before removing untracked files
    echo
    echo -n "Removing untracked files ..."
    if [[ "$clean_unktracked_files" == "y" ]]; then
        echo
        git clean -fd
    else
        echo -e "$color_blue Skipped$color_reset"
    fi

    # Delete unreferenced objects
    echo
    echo "Delete unreferenced objects ..."
    git prune -v

    echo
    echo -e "Git repo ${color_white}after${color_reset} maintainance:"
    git count-objects -vH

    popd &> /dev/null
}

# ------------------------------------------------------------------------------
# Main
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

git_mainteinance
