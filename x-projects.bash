#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xtra Scripts
#
# Projects management
# ------------------------------------------------------------------------------

set -e

SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SOURCE_DIR/_commons.bash"
source "$SOURCE_DIR/_spinner.bash"
source "$SOURCE_DIR/_settings.bash"

x_print_title "Projects"

# ------------------------------------------------------------------------------
# Settings

# Max deep search
max_depth=5

# ------------------------------------------------------------------------------
# Functions

function usage() {
    echo "Usage: $(basename "$0") [-p <projects root>] [-c] [-h | -?]"
    echo
    echo "Where:"
    echo "  -p <projects root>  - folder containing all the projects"
    echo "  -c                  - change dir"
    echo "  -h | -?             - shows this help screen"
}

function change_project_dir() {
    local projects_folder
    projects_folder=$(x_read_config "projects_folder" "$HOME/Projects/")

    echo -e "${icon_arrow_right}  Project root: ${color_white}${projects_folder}${color_reset}"

    if [ ! -d "$projects_folder" ]; then
        echo "Project folder does not exist: $projects_folder"
        return 1
    fi

    x_start_spinner "Searching projects"
    local project_candidates=()
    while IFS= read -r git_dir; do
        project_candidates+=("${git_dir%/.git}")
    done < <(find "$projects_folder" -maxdepth "$max_depth" -type d -name .git 2>/dev/null)
    x_stop_spinner "Done"

    if [ "${#project_candidates[@]}" -eq 0 ]; then
        echo
        echo "No Git projects found under $projects_folder"
        return 0
    fi

    local filtered_dirs=()
    local project_path
    local relative_path
    for project_path in "${project_candidates[@]}"; do
        relative_path="${project_path#$projects_folder}"
        relative_path="${relative_path#/}"
        relative_path="${relative_path%/}"

        [ -n "$relative_path" ] || continue

        local is_duplicate=false
        local filtered
        for filtered in "${filtered_dirs[@]}"; do
            if [[ "$relative_path" == *"$filtered"* ]]; then
                is_duplicate=true
                break
            fi
        done

        if [ "$is_duplicate" = false ]; then
            filtered_dirs+=("$relative_path")
        fi
    done

    echo
    echo -e "${icon_arrow_right}  Select project dir ('q' to quit):\n"

    local project_dir
    local goto_dir
    select project_dir in "${filtered_dirs[@]}"; do
        if [[ "$REPLY" == "Q" || "$REPLY" == "q" ]]; then
            break
        fi

        if [[ -z "$project_dir" ]]; then
            echo "'$REPLY' is not a valid selection"
            continue
        fi

        goto_dir="$projects_folder/$project_dir"
        echo
        echo -e "${icon_arrow_right}  Go to ${color_white}$goto_dir${color_reset}"

        cd "$goto_dir"
        exec "$SHELL"
    done
}

function save_project_dir() {
    echo "Setting new project folder .."
    echo
    x_write_config "projects_folder" "$1"
}

# ------------------------------------------------------------------------------
# Main

function main() {
    while getopts "hp:c" arg ; do
        case $arg in
            p)
                save_project_dir "${OPTARG}"
                # After changing the project folder the default operation is execute.
                # This allows checking whether the saved folder is valid immediately.
                # Then execute default function
                ;;
            c)
                : # Noop - Execute default function
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

    # Default operation is "change project dir"
    change_project_dir
}

main "$@"
