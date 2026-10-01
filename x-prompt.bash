#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xtra Scripts
#
# Fancy bash prompt
# ------------------------------------------------------------------------------

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SOURCE_DIR/_icons.bash"

# ------------------------------------------------------------------------------
# Functions

function x_colored_prompt() {
    local __user_and_host="\[\033[01;32m\]\u@\h"
    local __cur_location="\[\033[01;34m\]\w"
    local __git_branch_color="\[\033[31m\]"
    local __git_branch='`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/['"$icon_branch"'\ \\\\\1]\ /`'
    local __prompt_tail="\[\033[35m\]$"
    local __last_color="\[\033[00m\]"

    export PS1="$__user_and_host $__cur_location $__git_branch_color$__git_branch\n$__prompt_tail$__last_color "
}
