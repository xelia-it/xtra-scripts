#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Create release branch with related tags
# ------------------------------------------------------------------------------

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "Create release tags"

# ------------------------------------------------------------------------------
# Settings

# Git version and branch
git_version="0.0.0"
git_short_version="0.0.0"
is_first_version=true
current_branch=""

# Old and new version
major="0"
minor="0"
patch="0"

# User requests
add_develop_tag=false
ask_to_update_major=false
verbose=false

# ------------------------------------------------------------------------------
# Functions

usage() {
    echo "Usage: $(basename $0) [-M] [-h | -?]"
    echo
    echo "Where:"
    echo "  -M           - change major version"
    echo "  -v           - show verbose messages"
    echo "  -h | -?      - shows this help screen"
}

debug_message() {
    if [ $verbose == true ]; then
        echo -e $1
    fi
}

get_last_git_version() {
    # Check git version
    git_version=`git describe --match 'ver[0-9]*' --first-parent --dirty --long | sed -e 's|^ver||' -e 's|-|.|g'`
    if [ -z $git_version ]; then
        is_first_version=true
    else
        is_first_version=false
        git_short_version="$(cut -d '.' -f 1 <<< "$git_version")"."$(cut -d '.' -f 2 <<< "$git_version")"."$(cut -d '.' -f 3 <<< "$git_version")"
    fi

    debug_message "Last Git Version: $color_bright_white$git_version$color_reset"
    debug_message "Last Git Short Version: $color_bright_white$git_short_version$color_reset"
}

check_version_to_update() {
    # Check current branch
    current_branch=`git rev-parse --abbrev-ref HEAD`

    debug_message "Current branch: $color_bright_white$current_branch$color_reset"

    if [ $current_branch == "develop" ]; then
        if [ $ask_to_update_major == true ]; then
            debug_message "We are on develop and you asked to change major version"
        else
            if [ $is_first_version == true ]; then
                debug_message "We are on develop but no versions have been added yet"
            else
                debug_message "We are on develop: change minor version"
            fi
        fi
        add_develop_tag=true
    elif [[ $current_branch =~ "release" ]]; then
        if [ $ask_to_update_major == true ]; then
            x_fail "Cannot update major version on release branch"
        fi
        debug_message "We are in a release branch: update patch version"
        add_develop_tag=false
    else
        x_fail "Cannot create release branch from $current_branch"
    fi
}

calculate_new_tags() {
    major=`echo $git_short_version | cut -d. -f1`
    minor=`echo $git_short_version | cut -d. -f2`
    patch=`echo $git_short_version | cut -d. -f3`

    if [ $add_develop_tag == true ]; then
        if [ $is_first_version == true ]; then
            new_minor=$minor
            new_major=$major
        elif [ $ask_to_update_major == true ]; then
            new_major=`expr $major + 1`
            new_minor=0
        else
            new_major=$major
            new_minor=`expr $minor + 1`
        fi
        new_dev_tag="ver$new_major.$new_minor.0"
    fi

    cur_rel_tag="rel$major.$minor.$patch"
    new_patch=`expr $patch + 1`
    new_rel_tag="ver$major.$minor.$new_patch"
    new_rel_branch="release/v$major.$minor"

    debug_message "New development tag: $color_white$new_dev_tag$color_reset"
    debug_message "Current release tag: $color_white$cur_rel_tag$color_reset"
    debug_message "New release tag:     $color_white$new_rel_tag$color_reset"
    debug_message "New release branch:  $color_white$new_rel_branch$color_reset"
}

create_development_commit_and_tag() {
    git commit --allow-empty -m "Empty commit to tag $1 development"
    git tag $1 -a -m "Start $1 development"
}

create_release_commit_and_tag() {
    git commit --allow-empty -m "Empty commit to tag $1 release"
    git tag $1 -a -m "Release $1"
}

create_branches_and_tags() {
    if [ $add_develop_tag == true ]; then
        # We are in develop
        if [ $is_first_version == false ]; then
            git checkout -b $new_rel_branch
            create_release_commit_and_tag $cur_rel_tag
            create_development_commit_and_tag $new_rel_tag
            git checkout develop
        fi

        create_development_commit_and_tag $new_dev_tag
    else
        create_release_commit_and_tag $cur_rel_tag
        create_development_commit_and_tag $new_rel_tag
    fi
}

# ------------------------------------------------------------------------------
# Main

while getopts "hMv" arg ; do
    case $arg in
        M)
            ask_to_update_major=true
            ;;
        v)
            verbose=true
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

get_last_git_version
check_version_to_update
calculate_new_tags
create_branches_and_tags
