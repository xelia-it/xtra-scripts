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

# For Debian 12
build_packages=(
    build-essential autoconf automake texinfo gnutls-bin
)
dev_packages=(
    libgtk-3-dev xorg-dev libncurses-dev
    libjansson-dev libgccjit-12-dev libgnutls28-dev
    libxml2-dev libharfbuzz-dev libtree-sitter-dev libwebkit2gtk-4.0-dev
    librsvg2-dev libpoppler-glib-dev
    libxpm-dev libjpeg-dev libgif-dev libtiff-dev libpng-dev libgif-dev libtiff-dev
    libmagickwand-dev libmagickcore-dev
)
install_path=/opt/emacs


set DEV_PACKAGES=xorg-dev libgtk-3-dev \
  libjansson-dev libgccjit-12-dev \
  libncurses-dev libxml2-dev libjpeg-dev libpng-dev libgif-dev libtiff-dev \
  libgnutls28-dev librsvg2-dev \
  build-essential \
  gcc \
  g++ \
    make \
    autoconf \
    automake \
    texinfo \
    libgtk-3-dev \
    libxpm-dev \
    libjpeg-dev \
    libgif-dev \
    libtiff-dev \
    libncurses-dev \
    libgnutls28-dev \
    libjansson-dev \
    libharfbuzz-dev \
    libtree-sitter-dev \
    libgccjit-12-dev \
    libgccjit-12-doc \
    libgccjit-12-source \
    libmailutils-dev \
    libmagickwand-dev \
    libxml2-dev \
    libgtk-3-dev \
    libjson-c-dev \
    curl \
    ca-certificates \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev


sudo apt install -y "${dev_packages[@]}"

# ------------------------------------------------------------------------------
# Main

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

#sudo apt install -y "${build_packages[@]}"
sudo apt install -y $DEV_PACKAGES

echo
echo -e "${color_white}${icon_check_mark}${color_reset}: build packages installed"
echo

sudo apt install -y "${dev_packages[@]}"

echo
echo -e "${color_white}${icon_check_mark}${color_reset}: dev packages installed"
echo

./configure --prefix=$install_path \
            --with-native-compilation --with-tree-sitter  --with-imagemagick \
            --with-mailutils   --without-pop \
            CFLAGS="-O2 -march=native -pipe"

echo
echo -e "${color_white}${icon_check_mark}${color_reset}: configuration done"
echo

make -j$(nproc) VERBOSE=1

echo
echo -e "${color_white}${icon_check_mark}${color_reset}: build complete"
echo

#./configure --prefix=/opt/emacs --with-native-compilation --with-mailutils \
#    CFLAGS="-O3 -march=native -mtune=native" \
#    CXXFLAGS="-O3 -march=native -mtune=native" \
#    LDFLAGS="-Wl,-O1"
#
#make

echo
echo -e "${color_white}${icon_check_mark}${color_reset}: install complete"
echo

sudo apt purge -y "${dev_packages[@]}"

echo
echo -e "${color_white}${icon_check_mark}${color_reset}: cleanup complete"
echo
