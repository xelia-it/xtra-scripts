#!/bin/bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Automatic mainteinance for Git repositoy
# ------------------------------------------------------------------------------

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "Git Repo Mainteinance"

# ------------------------------------------------------------------------------
# Main

echo "Current folder: $(pwd)"

if [ ! -d ".git" ]; then
    echo "Error: not a git repository"
    exit 1
fi

# Garbage collection with immediate pruning and max compression
echo "Garbage collection ..."
git gc --prune=now --aggressive

# Removes invalid remote references
echo "Cleanup remote references ..."
git remote prune origin

# Verify repository integrity
echo "Verify repository integrity ..."
git fsck --full

# Ask confirmation before removing untracked files
read -p "Do you want to reove untracked files? (y/n): " CLEAN_CONFIRM
if [[ "$CLEAN_CONFIRM" == "y" ]]; then
    echo "Removing untracked files ..."
    git clean -fd
else
    echo "Skip untracked files removal."
fi

# Delete unreferenced objects
echo "Delete unreferenced objects ..."
git prune -v

echo "Done!"
