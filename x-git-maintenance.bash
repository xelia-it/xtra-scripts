#!/bin/bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Git repository info and maintenance
# ------------------------------------------------------------------------------

set -e

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SOURCE_DIR/_colors.bash"
source "$SOURCE_DIR/_commons.bash"
source "$SOURCE_DIR/_settings.bash"

x_print_title "Git Repo Maintenance"

# ------------------------------------------------------------------------------
# Settings

project_folder=$(pwd)
operation="info"
clean_untracked="n"

# ------------------------------------------------------------------------------
# Functions

usage() {
    echo "Usage: $(basename $0) [-i | -c] [-p <project>] [-h | -?]"
    echo
    echo "Where:"
    echo "  -i              - show repository info and statistics (default)"
    echo "  -c              - cleanup and maintenance"
    echo "  -p <project>    - project root folder"
    echo "  -h | -?         - shows this help screen"
}

check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        x_fail "Not a Git repo"
        exit 1
    fi
}

show_repo_info() {
    echo -e "$color_white$icon_arrow_right$color_reset Current directory: $color_white$(pwd)$color_reset"
    echo

    pushd . &> /dev/null
    cd "$project_folder"
    check_git_repo

    echo -e "${color_bright_white}📊 REPOSITORY STATISTICS${color_reset}"
    echo
    echo -e "$color_white$icon_arrow_right$color_reset Object count:"
    git count-objects -vH
    echo


    echo -e "$color_white$icon_arrow_right$color_reset Local branches:"
    local_count=$(git branch | wc -l)
    echo "  Total: $local_count"
    git branch --list
    echo

    echo -e "$color_white$icon_arrow_right$color_reset Remote branches:"
    remote_count=$(git branch -r | wc -l)
    echo "  Total: $remote_count"
    echo

    echo -e "$color_white$icon_arrow_right$color_reset Repository status:"
    git status --short
    if [ $? -eq 0 ] && [ -z "$(git status --short)" ]; then
        echo "  Working tree clean ✓"
    fi
    echo

    echo -e "$color_white$icon_arrow_right$color_reset Commits to push:"
    local unpushed=$(git log --oneline @{u}.. 2>/dev/null | wc -l || echo 0)
    echo "  $unpushed commit(s)"
    echo

    popd &> /dev/null
}

do_cleanup() {
    echo -e "$color_white$icon_arrow_right$color_reset Current directory: $color_white$(pwd)$color_reset"
    echo

    pushd . &> /dev/null
    cd "$project_folder"
    check_git_repo

    echo -e "${color_bright_white}🧹 CLEANUP AND MAINTENANCE${color_reset}"
    echo

    # Garbage collection with immediate pruning and max compression
    echo -e "$color_white$icon_arrow_right$color_reset Garbage collection..."
    git gc --prune=now --aggressive
    echo

    # Removes invalid remote references
    echo -e "$color_white$icon_arrow_right$color_reset Cleanup remote references..."
    git remote prune origin
    echo

    # Verify repository integrity
    echo -e "$color_white$icon_arrow_right$color_reset Integrity check..."
    git fsck --full
    echo

    # Ask confirmation before removing untracked files
    echo -e -n "$color_white$icon_arrow_right$color_reset Cleanup untracked files..."
    if [[ "$clean_untracked" == "y" ]]; then
        echo
        git clean -fd
    else
        echo -e " $color_blue Skipped$color_reset"
    fi
    echo

    # Delete unreferenced objects
    echo -e "$color_white$icon_arrow_right$color_reset Clean unreferenced objects..."
    git prune -v
    echo

    echo -e "$color_white$icon_arrow_right$color_reset Final statistics:"
    git count-objects -vH
    echo

    echo -e "$icon_check_mark Complete"

    popd &> /dev/null
}

# ------------------------------------------------------------------------------
# Main

while getopts "hicep:" arg ; do
    case $arg in
        i)
            operation="info"
            ;;
        c)
            operation="cleanup"
            ;;
        p)
            project_folder=${OPTARG}
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

case "$operation" in
    info)
        show_repo_info
        ;;
    cleanup)
        do_cleanup
        ;;
esac
