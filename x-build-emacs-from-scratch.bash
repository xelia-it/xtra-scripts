#!/bin/bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Build emacs from source
# ------------------------------------------------------------------------------

source _colors.bash
source _commons.bash

x_print_title "Install emacs from source"

# ------------------------------------------------------------------------------
# Settings

set DEV_PACKAGES=xorg-dev libgtk-3-dev \
  libjansson-dev libgccjit-12-dev \
  libncurses-dev libxml2-dev libjpeg-dev libpng-dev libgif-dev libtiff-dev \
  libgnutls28-dev librsvg2-dev

# TODO: For debian 11
# sudo apt install build-essential xorg-dev libgtk2.0-dev \
# libjpeg-dev libgif-dev libtiff-dev libncurses5-dev libjansson-dev libgccjit-10-dev

# ------------------------------------------------------------------------------

x_ensure_user_is_root

if ! [ -x ./configure ]; then
    x_fail "this folder seems not contain Emacs sources"
fi

num_of_emacs_words=`grep "GNU Emacs" .gitignore | wc -l`
if [ $num_of_emacs_words -eq 0 ]; then
    x_fail "this folder seems not contain Emacs sources"
fi

echo
echo -e "${color_white}${icon_check_mark}${color_reset}: it seems Emacs source"
echo

# For Debian 12

sudo apt install -y build-essential $DEV_PACKAGES
echo
echo -e "${color_white}${icon_check_mark}${color_reset}: required packages installed"
echo

./configure --prefix=/opt/emacs --with-native-compilation --with-mailutils
make
sudo make install
sudo apt purge -y $DEV_PACKAGES
