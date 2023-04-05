#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Find characteristics of web projects
# ------------------------------------------------------------------------------

# TODO: current limitations:
# - Should be run inside the project folder
# - A parameter to set project folder should be added
# - It should recognize if an Angular project is present in this folder

ret= \
    grep -r -i -n 'material-icon' src/ | \
    grep -E '<span.+</span>' | \
    sed -e 's/\(.*\)<span\(.*\)>\(.*\)<\/span>/\3/' | \
    sed 's: ::g' | \
    grep -x '[a-z\_ ]\+' | \
    sort | uniq

echo $ret
