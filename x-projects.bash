#!/usr/bin/env bash

source _commons.bash
source _spinner.bash
source _settings.bash

x_print_title "Projects"

# Settings
projects_folder=$(x_read_config "projects_folder" $HOME/Projects/)
escaped_project_folder=${projects_folder//\//\\/}
max_depth=5

# Print header ans search spinner
echo -e "${icon_folder_outline_open}  Project root: ${color_white}${projects_folder}${color_reset}"
x_start_spinner " Searching projects"
dirs=`find ${projects_folder} -maxdepth ${max_depth} -name .git`
x_stop_spinner "Done"

# Now show filtered results
abbrev_dirs=$((IFS=$'\n' && echo "${dirs[*]}") | sed "s/${escaped_project_folder}//" | sed "s/\.git//" | sort)
echo

filtered_dirs=()
for abbrev in ${abbrev_dirs[@]}
do
    found=0
    for filtered in ${filtered_dirs[@]}
    do
        if [[ $abbrev == *$filtered* ]]; then
            found=1
            break
        fi
    done

    if [[ $found -eq 0 ]]; then
        # Remove project dir from found folder
        without_project_folder=$(x_string_remove_pattern ${abbrev} ${projects_folder})
        filtered_dirs+=($without_project_folder)
    fi
done

# Allow the user to choose a file
echo "Select project dir ('q' to quit):"
select project_dir in ${filtered_dirs[@]}
do
    # leave the loop if the user says 'x'
    if [[ "$REPLY" == "Q" || "$REPLY" == "q" ]]; then break; fi

    # complain if no file was selected, and loop to ask again
    if [[ "$project_dir" == "" ]]
    then
        echo "'$REPLY' is not a valid number"
        continue
    fi

    # Now we can use the selected element
    goto_dir=$projects_folder/$project_dir
    echo
    echo -e "Go to ${color_white}$goto_dir${color_reset}"

    cd $goto_dir
    $SHELL

    # it'll ask for another unless we leave the loop
    break
done
