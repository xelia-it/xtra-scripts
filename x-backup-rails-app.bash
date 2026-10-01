#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xtra Scripts
#
# Backup Rails app
# ------------------------------------------------------------------------------

set -e

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SOURCE_DIR/_colors.bash"
source "$SOURCE_DIR/_commons.bash"
source "$SOURCE_DIR/_settings.bash"

x_print_title "Backup Rails App"

# ------------------------------------------------------------------------------
# Settings

rails_folder=
db_username=
db_password=
db_name=
backup_folder="$HOME/backup"
hostname="$(hostname)"
timestamp="$(date --utc +%Y%m%d%H%M%S)"
db_filename="${timestamp}-${hostname}-backup-db"
storage_filename="${timestamp}-${hostname}-backup-storage"
verbose=false

# ------------------------------------------------------------------------------
# Functions

function usage() {
    echo "Usage:"
    echo "    $(basename "$0") [-b <backup folder>]"
    echo "    -r <rails folder>"
    echo "    -d <db name> -u <db username> -p <db password>"
    echo "    [-v] [-h | -?]"
}

function print_settings() {
    echo -e "Folders:"
    echo -e "  Rails:    ${color_white}${rails_folder}${color_reset}"
    echo -e "  Backup:   ${color_white}${backup_folder}${color_reset}"
    echo

    echo -e "Database:"
    echo -e "  Username: ${color_white}${db_username}${color_reset}"
    echo

    echo -e "Backups:"
    echo -e "  DB:       ${color_white}${db_filename}.tar.bz2${color_reset}"
    echo -e "  Storage:  ${color_white}${storage_filename}.tar.bz2${color_reset}"
    echo
}

function check_params() {
    if [ -z "$rails_folder" ]; then
        x_fail "Rails folder cannot be empty"
    fi
    if [ ! -d "$rails_folder" ]; then
        x_fail "Rails folder does not exist"
    fi
    if [ ! -d "$rails_folder/storage" ]; then
        x_fail "Rails storage folder does not exist"
    fi
    mkdir -p -- "$backup_folder"
    if [ ! -d "$backup_folder" ]; then
        x_fail "Backup folder cannot be created"
    fi
    if [ -z "$db_name" ]; then
        x_fail "DB name cannot be empty"
    fi
    if [ -z "$db_username" ]; then
        x_fail "DB username cannot be empty"
    fi
    if [ -z "$db_password" ]; then
        x_fail "DB password cannot be empty"
    fi
}

function do_backup() {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap 'rm -rf -- "$tmp_dir"' EXIT

    local db_dump_path="$tmp_dir/${db_filename}.sql"
    local db_archive_path="$backup_folder/${db_filename}.tar.bz2"
    local storage_archive_path="$backup_folder/${storage_filename}.tar.bz2"

    echo "Creating DB backup ..."
    export PGPASSWORD="$db_password"
    if ! pg_dump -U "$db_username" -h localhost -d "$db_name" > "$db_dump_path"; then
        echo
        x_fail "DB backup failed: aborting"
    fi
    tar -cjf "$db_archive_path" -C "$tmp_dir" "$(basename "$db_dump_path")"
    rm -f -- "$db_dump_path"

    echo "Creating storage backup ..."
    tar -cjf "$storage_archive_path" -C "$rails_folder" storage
}

# ------------------------------------------------------------------------------
# Main

function main() {
    while getopts "b:r:d:u:p:hv" arg ; do
        case $arg in
            b)
                backup_folder=${OPTARG}
                ;;
            r)
                rails_folder=${OPTARG}
                ;;
            d)
                db_name=${OPTARG}
                ;;
            u)
                db_username=${OPTARG}
                ;;
            p)
                db_password=${OPTARG}
                ;;
            v)
                verbose=true
                ;;
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

    print_settings
    check_params
    do_backup
}

main "$@"
