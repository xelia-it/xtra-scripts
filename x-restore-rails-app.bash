#!/bin/bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Backup a Rails App
# ------------------------------------------------------------------------------

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "Restore Rails App"

# ------------------------------------------------------------------------------
# Settings

rails_folder=
db_username=
db_password=
db_name=
db_backup_filename=
storage_backup_filename=

# ------------------------------------------------------------------------------
# Functions

usage () {
    echo "Usage:"
    echo "    $0 -b <backup filename> -s <storage filename>"
    echo "    -r <rails folder>"
    echo "    -d <db name> -u <db username> -p <db password>"
    echo "    [-v] [-h|-?]"
}

print_settings() {
    echo -e "Folders:"
    echo -e "  Rails:    ${color_white}${rails_folder}${color_reset}"
    echo

    echo -e "Database:"
    echo -e "  Username: ${color_white}${db_username}${color_reset}"
    echo

    echo -e "Backups:"
    echo -e "  DB:       ${color_white}${db_backup_filename}${color_reset}"
    echo -e "  Storage:  ${color_white}${storage_backup_filename}${color_reset}"
    echo
}

check_params() {
    if [ "$rails_folder" == "" ]; then
        x_fail "Rails folder cannot be empty"
    fi
    if ! [ -d $rails_folder ]; then
        x_fail "Rails folder do not exists"
    fi
    if ! [ -f $db_backup_filename ]; then
        x_fail "DB backup filename do not exists"
    fi
    if ! [ -f $storage_backup_filename ]; then
        x_fail "Storage backup filename do not exists"
    fi
    if [ "$db_name" == "" ]; then
        x_fail "DB name cannot be empty"
    fi
    if [ "$db_username" == "" ]; then
        x_fail "DB username cannot be empty"
    fi
    if [ "$db_password" == "" ]; then
        x_fail "DB password cannot be empty"
    fi
}

do_restore() {
    backup_file_type=`file $db_backup_filename`
    if [[ $? -ne 0 ]]; then
        x_fail "Failed to retrieve file type"
    fi
    echo backup_file_type
    if [[ $backup_file_type = *"gzip"* ]]; then
        echo "File $db_backup_filename is compressed with gzip"
        zcat $db_backup_filename > $db_backup_filename.tmp
    else
        if [[ $backup_file_type = *"bz2"* ]]; then
            echo "File $db_backup_filename is compressed with bz2"
            bzcat $db_backup_filename > $db_backup_filename.tmp
        else
            echo "Assume $1 is a plain text"
            cp $db_backup_filename  > $db_backup_filename.tmp
        fi
    fi

    echo "Restore DB backup ..."
    export PGPASSWORD=$db_password
    psql -U $db_username -h localhost $db_name < $db_backup_filename.tmp
    if [ $? -ne 0 ]; then
        x_fail "DB backup failed: aborting"
    fi
    rm $db_backup_filename.tmp

    echo "Restore storage backup ..."
    mkdir -p $rails_folder/storage
    tar jxf $storage_backup_filename -C $rails_folder #/storage
}

# ------------------------------------------------------------------------------
# Main

while getopts "b:s:r:d:u:p:hv" arg ; do
    case $arg in
        b)
            db_backup_filename=${OPTARG}
            ;;
        s)
            storage_backup_filename=${OPTARG}
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
        h | ?)
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
do_restore
