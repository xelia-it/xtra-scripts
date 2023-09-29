#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Find characteristics of web projects
# ------------------------------------------------------------------------------

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "Web Scan"

# TODO: current limitations:
# - Should be run inside the project folder
# - A parameter to set project folder should be added
# - It should recognize if an Angular project is present in this folder

function find_material_icons() {
    ret= \
        grep -r -i -n 'material-icon' * | \
        grep -E '<span.+</span>' | \
        sed -e 's/\(.*\)<span\(.*\)>\(.*\)<\/span>/\3/' | \
        sed 's: ::g' | \
        grep -x '[a-z\_ ]\+' | \
        sort | uniq

    echo $ret
}

function find_ids() {
    ret= \
       grep -i -n -r -E -o --exclude="node_modules" --exclude="src-ext" --exclude="*.svg" --exclude="*.ts" --exclude="*.js" 'id="[a-z_]+"' * | \
        cut -d':' -f3 | \
        cut -d'"' -f2 | \
        sort | uniq

    echo $ret
}

for id in $(find_material_icons)
do
    echo $id
done
