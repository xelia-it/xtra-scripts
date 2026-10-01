#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xtra Scripts
#
# Show git tags
# ------------------------------------------------------------------------------

set -e

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SOURCE_DIR/_colors.bash"
source "$SOURCE_DIR/_commons.bash"

x_print_title "Show git tags"

# ------------------------------------------------------------------------------
# Functions

function usage() {
    echo "Usage: $(basename "$0") [-h | -?]"
    echo
    echo "Where:"
    echo "  -h | -?      - shows this help screen"
}

function show_tags() {
    git for-each-ref \
        --format="%(if:equals=tag)%(objecttype)%(then)a %(else)%(if:equals=blob)%(objecttype)%(then)b %(else)  %(end)%(end)%(align:20,right)%(refname:short)%09%(objectname:short)%(end)%09%(if:equals=tag)%(objecttype)%(then)@%(object) %(contents:subject)%(else)%(end)" \
        --sort=taggerdate \
        refs/tags
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

    show_tags
}

main "$@"
