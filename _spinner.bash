# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Draw spinner for long jobs
#
# Original code from: https://github.com/tlatsas/bash-spinner (MIT License)
# Author: Tasos Latsas
# ------------------------------------------------------------------------------

source _colors.bash
source _icons.bash

# start_spinner($message)
#
# Start a spinner.
# If $message is specified then it will be printed after the spinner.
function x_start_spinner {
    # $1 : msg to display
    __spinner "start" "${1}" &
    # set global spinner pid
    __sp_pid=$!
    disown
}

# stop_spinner($message)
#
# Stop the last spinner.
# The $message is currently ignored.
function x_stop_spinner {
    # $1 : command exit status
    __spinner "stop" $1 $__sp_pid
    unset __sp_pid
}

# Private

function __spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success=$icon_check_mark
    local on_fail=$icon_cross_mark

    # Declarative array of all icons.
    # Please note that the array starts from 1.
    num_icons=11
    declare -A icons
    icons[1]=${icon_dots_1}
    icons[2]=${icon_dots_2}
    icons[3]=${icon_dots_3}
    icons[4]=${icon_dots_4}
    icons[5]=${icon_dots_5}
    icons[6]=${icon_dots_6}
    icons[7]=${icon_dots_7}
    icons[8]=${icon_dots_8}
    icons[9]=${icon_dots_9}
    icons[10]=${icon_dots_10}
    icons[${num_icons}]=${icon_dots_11}

    # Starting column of the message (0 based).
    # The spinner is 2 columns on the left.
    # Example: if column is 5 the Message starts from the 6th column.
    # The spinner (S) is printed on 4th column.
    #
    # 0....5....0
    #
    #    S Message
    #      ^
    #      |
    #      +--- column
    #
    local column=2

    case $1 in
        start)
            # Take space display message and position the cursor in $column column
            printf "%${column}s${2}"
            echo -en "\\033[${column}G"

            # Hide cursor
            tput civis

            # start spinner
            idx=1
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b"
                echo -en "$color_white"

                idx=$(($idx + 1))
                if [ $idx -gt $num_icons ]; then
                    idx=1
                fi
                echo -en ${icons[$idx]}
                echo -en "$color_reset"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # Set cursor as normal (visible)
            tput cnorm

            # inform the user uppon success or failure
            echo -en "\b"
            if [[ $2 -eq 0 ]]; then
                echo -e "${color_green}${on_success}${color_reset}"
            else
                echo -e "${color_red}${on_fail}${color_reset}"
            fi
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}
