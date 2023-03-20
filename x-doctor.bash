#!/bin/bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Script diagnostic tool
# ------------------------------------------------------------------------------

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "Doctor"

xelia_scripts_folder=$(x_script_folder)
xelia_scripts_version=`git --git-dir="${xelia_scripts_folder}/.git" describe --first-parent --abbrev=0`
echo -e "${x_xelia_scripts_name}:"
echo -e "  Installed in: ${color_white}${xelia_scripts_version}${color_reset}"
echo -e "  Installed in: ${color_white}${xelia_scripts_folder}${color_reset}"
echo

echo "User folders:"
echo -e "  Config:       ${color_white}${x_conf_folder_config}${color_reset}"
echo -e "  Cache:        ${color_white}${x_conf_folder_cache}${color_reset}"
echo -e "  Data:         ${color_white}${x_conf_folder_data}${color_reset}"
echo -e "  State:        ${color_white}${x_conf_folder_state}${color_reset}"
echo

projects_folder=$(x_read_config "projects_folder" $HOME/Projects/)
echo "Projects:"
echo -e "  Root folder:  ${color_white}${projects_folder}${color_reset}"
