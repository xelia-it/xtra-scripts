#!/bin/bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Cleanup system
# ------------------------------------------------------------------------------

set -e

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "System cleanup"

# ------------------------------------------------------------------------------
# Main

x_ensure_user_is_root

echo -e "$color_white$icon_arrow_right_bar$color_reset Clean apt cache..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo apt-get clean -y

echo -e "$color_white$icon_arrow_right_bar$color_reset Remove cache and lock file cache no more used..."
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /var/cache/apt/archives/*
sudo rm -rf /var/cache/*

echo -e "$color_white$icon_arrow_right_bar$color_reset Cleanup old logs..."
sudo journalctl --vacuum-time=7d
sudo journalctl --rotate
sudo journalctl --vacuum-size=100M

echo -e "$color_white$icon_arrow_right_bar$color_reset Cleanup thumbnails..."
rm -rf ~/.cache/thumbnails/*

echo -e "$color_white$icon_arrow_right_bar$color_reset Cleanup Docker (if present)..."
if command -v docker >/dev/null 2>&1; then
    docker system prune -af # --volumes
fi

echo -e "$color_white$icon_arrow_right_bar$color_reset Cleanup pip cache..."
rm -rf ~/.cache/pip

echo -e "$color_white$icon_arrow_right_bar$color_reset Cleanup npm cache (if present)..."
if command -v npm >/dev/null 2>&1; then
    npm cache clean --force
fi

echo -e "$color_white$icon_arrow_right_bar$color_reset Cleanup with flatpak (if present)..."
if command -v flatpak >/dev/null 2>&1; then
    flatpak uninstall --unused -y
fi

echo -e "$color_white$icon_arrow_right_bar$color_reset Cleanup complete!"
