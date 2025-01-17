#!/bin/bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Backup a Rails App
# ------------------------------------------------------------------------------

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "Backup Rails App"

# ------------------------------------------------------------------------------
# Settings

rails_folder=
db_username=
db_password=
db_name=
backup_folder=~/backup
hostname=`hostname`
timestamp=`date --utc +%Y%m%d%H%M%S`
db_filename=$timestamp-$hostname-backup-db
storage_filename=$timestamp-$hostname-backup-storage

usage () {
    echo "Usage:"
    echo "    $0 [-b <backup folder>] [-r <rails folder>]"
    echo "    [-d <db name>] [-u <db username>] [-p <db password>]"
    echo "    [-v] [-h|-?]"
}


print_settings() {
    echo -e "Folders:"
    echo -e "  Rails:    ${color_white}${rails_folder}${color_reset}"
    echo -e "  Backup:   ${color_white}${backup_folder}${color_reset}"
    echo

    echo -e "Database:"
    echo -e "  Username: ${color_white}${db_username}${color_reset}"
    echo

    echo -e "Backups:"
    echo -e "  DB:       ${color_white}${db_filename}.bz2${color_reset}"
    echo -e "  Storage:  ${color_white}${storage_filename}.bz2${color_reset}"
    echo
}

check_params() {
    if [ "$rails_folder" == "" ]; then
        x_fail "Rails folder cannot be empty"
    fi
    if ! [ -d $rails_folder ]; then
        x_fail "Rails folder do not exists"
    fi
    if ! [ -d $rails_folder/storage ]; then
        x_fail "Rails storage folder do not exists"
    fi
    if ! [ -d $backup_folder ]; then
        x_fail "Backup folder do not exists"
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

make_backup() {
    echo "Creating DB backup ..."
    export PGPASSWORD=$db_password
    pg_dump -U $db_username -W -h localhost -d $db_name > $db_filename.sql
    if [ $? -gt 0 ]; then
        echo
        x_fail "DB backup failed: aborting"
    fi
    tar jcf $db_filename.tar.bz2 $db_filename.sql
    mv $db_filename.tar.bz2 $backup_folder
    rm $db_filename.sql

    echo "Creating storage backup ..."
    pushd . > /dev/null
    cd $rails_folder
    tar jcf $storage_filename.tar.bz2 storage
    mv $storage_filename.tar.bz2 $backup_folder
    popd > /dev/null
}

make_storage_backup() {
    echo "Creating storage backup ..."
    tar -czf $storage_filename -C $rails_folder/storage .
}

# ------------------------------------------------------------------------------
# Main

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
make_backup
make_backup_storage
