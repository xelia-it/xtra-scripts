# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Configuration
# ------------------------------------------------------------------------------

# Name of the whole project
x_xelia_scripts_name="Xelia Scripts"

# Folder for user-specific configuration files
# (analogous to /etc).
x_conf_folder_config=$XDG_CONFIG_HOME
if [ -z $x_conf_folder_config ]; then
    x_conf_folder_config=$HOME/.config
fi

# Folder for user-specific cached data
# (analogous to /var/cache).
x_conf_folder_cache=$XDG_CACHE_HOME
if [ -z $x_conf_folder_cache ]; then
    x_conf_folder_cache=$HOME/.cache
fi

# Folder for user-specific data files
# (analogous to /usr/share).
x_conf_folder_data=$XDG_DATA_HOME
if [ -z $x_conf_folder_data ]; then
    x_conf_folder_data=$HOME/.local/share
fi

# Folder for user-specific state
# (analogous to /var/lib).
x_conf_folder_state=$XDG_STATE_HOME
if [ -z $x_conf_folder_state ]; then
    x_conf_folder_state=$HOME/.local/state
fi

# x_read_config($parameter)
#
# Read parameter from config file.
#
x_read_config() {
    if [ "$1" == "" ]; then
        echo "Missing parameter name"
        exit 1
    fi
    if [ "$2" == "" ]; then
        echo "Missing default parameter value"
        exit 1
    fi
    config_full_name="${x_conf_folder_config}/.xelia_scripts"
    if [ ! -r $config_full_name ]; then
        echo $2
    else
        cat ${config_full_name}
        echo "BOOH"
    fi
}
