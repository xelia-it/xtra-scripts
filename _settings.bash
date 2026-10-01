# ------------------------------------------------------------------------------
# Xtra Scripts
#
# Configuration
# ------------------------------------------------------------------------------

# Name of the whole project
x_xtra_scripts_name="Xtra Scripts"

# Subfolder for config file
x_xtra_script_subfolder="xtra-scripts"

# Folder for user-specific configuration files
# (analogous to /etc).
x_conf_folder_config="${XDG_CONFIG_HOME:-$HOME/.config}"

# Folder for user-specific cached data
# (analogous to /var/cache).
x_conf_folder_cache="${XDG_CACHE_HOME:-$HOME/.cache}"

# Folder for user-specific data files
# (analogous to /usr/share).
x_conf_folder_data="${XDG_DATA_HOME:-$HOME/.local/share}"

# Folder for user-specific state
# (analogous to /var/lib).
x_conf_folder_state="${XDG_STATE_HOME:-$HOME/.local/state}"

# x_read_config($parameter)
#
# Read parameter from config file.
#
x_read_config() {
    if [ -z "${1:-}" ]; then
        echo "Missing parameter name"
        exit 1
    fi
    if [ -z "${2:-}" ]; then
        echo "Missing default parameter value"
        exit 1
    fi

    local config_full_name
    config_full_name=$(x_config_full_name "$1")
    if [ ! -r "$config_full_name" ]; then
        printf '%s\n' "$2"
    else
        cat "$config_full_name"
    fi
}

x_write_config() {
    if [ -z "${1:-}" ]; then
        echo "Missing parameter name"
        exit 1
    fi
    if [ -z "${2:-}" ]; then
        echo "Missing parameter value"
        exit 1
    fi

    mkdir -p -- "$(x_config_full_path)"
    local config_full_name
    config_full_name=$(x_config_full_name "$1")
    printf '%s\n' "$2" > "$config_full_name"
}

x_config_full_path() {
    printf '%s\n' "${x_conf_folder_config}/${x_xtra_script_subfolder}"
}

x_config_full_name() {
    printf '%s\n' "${x_conf_folder_config}/${x_xtra_script_subfolder}/${1}"
}
