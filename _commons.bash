# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Common functions
# ------------------------------------------------------------------------------

source _colors.bash
source _icons.bash

# x_print_title($message)
#
# Print main script title.
# If $message is empty nothing will be printed.
#
function x_print_title() {
    if [ -n "$1" ]; then
        echo -e "${color_white}${color_on_red}${icon_heavy_right_pointing_angle}${icon_heavy_left_pointing_angle}${color_reset} ${color_red}$1${color_reset}"
        echo
    fi
}

# x_print_subtitle($message)
#
# Print subtitle.
# If $message is empty nothing will be printed.
#
function x_print_subtitle() {
    if [ -n "$1" ]; then
        echo -e "$color_bright_white $1 $color_reset"
        echo
    fi
}

# x_print_error($message)
#
# Print an error message.
# If $message is empty nothing will be printed.
#
function x_print_error() {
    if [ -n "$1" ]; then
        echo -e "$color_bright_red$icon_cross_mark$color_reset $1"
        echo
    fi
}

# x_check_user_is_root()
#
# Ensure that the script is run by root user.
#
function x_check_user_is_root() {
    if [ "$euid" -ne 0 ]; then
        echo -e "This script must be executed as root."
        exit 1
    fi
}

# x_script_folder()
#
# Returns the current script folder.
#
function x_script_folder() {
    local folder="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
    echo ${folder}
}

# x_script_filename()
#
# Returns the base name of the script.
#
function x_script_filename() {
    local filename=`basename $0`
    echo ${filename}
}

# x_string_remove_pattern($original, $pattern)
#
# Removes $pattern occurences from $original string.
#
function x_string_remove_pattern() {
    echo "${1//$2}"
}

# x_ensure_user_is_root
#
# Exit with error code 1 if the user is not root (or sudo).
#
function x_ensure_user_is_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}
