#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xtra Scripts
#
# Extract MIME attachments
# ------------------------------------------------------------------------------

set -e

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SOURCE_DIR/_colors.bash"
source "$SOURCE_DIR/_commons.bash"

x_print_title "Extract MIME attachments"

# ------------------------------------------------------------------------------
# Settings

input_file=
outdir="allegati_estratti"

# ------------------------------------------------------------------------------
# Functions

function usage() {
    echo "Usage: $(basename "$0") <input file> [-h | -?]"
    echo
    echo "Where:"
    echo "  <input file>  - log/email file containing base64 MIME attachments"
    echo "  -h | -?       - shows this help screen"
}

function check_params() {
    if [ "$input_file" == "" ]; then
        x_fail "Input file cannot be empty"
    fi
    if ! [ -f "$input_file" ]; then
        x_fail "Input file do not exists"
    fi
}

function extract_attachments() {
    mkdir -p "$outdir"

    local part_counter=0
    declare -A name_count

    local in_base64=0
    local filename=""
    local mimetype=""
    local base64file=""
    local line
    local rawname
    local ext
    local base
    local count
    local name

    while IFS= read -r line || [ -n "$line" ]; do
        # Estrai filename
        if echo "$line" | grep -i "filename=" >/dev/null; then
            rawname=$(echo "$line" | sed -n 's/.*filename=["]*\([^";]*\).*/\1/p')
            filename="$rawname"
            continue
        fi

        # Estrai MIME type
        if echo "$line" | grep -i "^Content-Type:" >/dev/null; then
            mimetype=$(echo "$line" | sed -n 's/Content-Type:[ \t]*\([^;]*\).*/\1/p')
            continue
        fi

        # Inizio contenuto base64
        if echo "$line" | grep -i "Content-Transfer-Encoding: base64" >/dev/null; then
            in_base64=1
            part_counter=$((part_counter + 1))

            # Se filename non presente, usane uno automatico
            if [ -z "$filename" ]; then
                ext=$(echo "$mimetype" | tr '/' '-')
                filename="part-$(printf "%04d" $part_counter).$ext"
            fi

            # Se nome già esiste, aggiungi (1), (2), ...
            base="$filename"
            count="${name_count[$filename]}"
            if [ -n "$count" ]; then
                count=$((count + 1))
                name_count[$filename]=$count
                ext="${filename##*.}"
                name="${filename%.*}"
                filename="${name}($count).$ext"
            else
                name_count[$filename]=0
            fi

            base64file="$outdir/$filename.base64"
            echo -n "" > "$base64file"
            continue
        fi

        # Salta riga vuota
        if [ "$in_base64" -eq 1 ] && [ -z "$line" ]; then
            continue
        fi

        # Raccoglie righe base64
        if [ "$in_base64" -eq 1 ]; then
            if echo "$line" | grep -Eq '^[A-Za-z0-9+/=]+$'; then
                echo "$line" >> "$base64file"
            else
                echo -e "${color_green}${icon_check_mark}${color_reset}  Salvato: $base64file"
                in_base64=0
                filename=""
                base64file=""
                mimetype=""
            fi
        fi
    done < "$input_file"
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

    input_file="$1"

    check_params
    extract_attachments
}

main "$@"
