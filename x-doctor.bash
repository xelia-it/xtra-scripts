#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xtra Scripts
#
# Doctor
# ------------------------------------------------------------------------------

set -e

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SOURCE_DIR/_colors.bash"
source "$SOURCE_DIR/_commons.bash"
source "$SOURCE_DIR/_settings.bash"

x_print_title "Doctor"

# ------------------------------------------------------------------------------
# Settings

# External tools to check
commands=(sed grep sort uniq)

# ------------------------------------------------------------------------------
# Functions

function usage() {
    echo "Usage: $(basename "$0") [-h | -?]"
    echo
    echo "Where:"
    echo "  -h | -?      - shows this help screen"
}

function show_package_info() {
    local xelia_scripts_folder=$(x_script_folder)
    local xelia_scripts_version=`git --git-dir="${xelia_scripts_folder}/.git" describe --first-parent --abbrev=0`
    echo -e "Package:"
    echo -e "  Name:          ${color_white}${x_xtra_scripts_name}${color_reset}"
    echo -e "  Version:       ${color_white}${xelia_scripts_version}${color_reset}"
    echo -e "  Installed in:  ${color_white}${xelia_scripts_folder}${color_reset}"
    echo
}

function show_user_folders() {
    echo "User folders:"
    echo -e "  Config:        ${color_white}${x_conf_folder_config}${color_reset}"
    echo -e "  Cache:         ${color_white}${x_conf_folder_cache}${color_reset}"
    echo -e "  Data:          ${color_white}${x_conf_folder_data}${color_reset}"
    echo -e "  State:         ${color_white}${x_conf_folder_state}${color_reset}"
    echo
}

function show_projects_info() {
    local projects_folder=$(x_read_config "projects_folder" "$HOME/Projects/")
    echo "Projects:"
    echo -e "  Root folder:   ${color_white}${projects_folder}${color_reset}"
    echo
}

function show_external_tools() {
    echo "External tools:"
    local idx
    for idx in "${!commands[@]}"; do
        printf "  %-15s" "${commands[idx]}"
        which "${commands[idx]}" > /dev/null 2> /dev/null && echo -e "${color_green}FOUND${color_reset}" || echo -e "${color_red}MISSING${color_reset}"
    done
}

# ------------------------------------------------------------------------------
# Main

function main() {
    while getopts "h" arg ; do
        case $arg in
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

    show_package_info
    show_user_folders
    show_projects_info
    show_external_tools
}

main "$@"
