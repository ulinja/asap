#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Installs Saplib to the system. Updates existing Saplib installations.
# 
# The first and only argument supplied to this script is optional and is used
# as the target system's root folder.
# Example: you are installing to a pre-chroot system mounted at '/mnt', thus you
# can supply '/mnt' as an argument. Do not append a slash if you are supplying
# an argument.
# ----------------------------------------------------------------------------- #
# @file    install.bash
# @version 1.0
# @author  cybork
# @email   
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

THIS_DIR="$(dirname $(realpath $0))"
BUILD_DIR="$THIS_DIR/../build"

ROOT_DIR="$1"

# number of arguments must not exceed 1
if [ "$#" -gt 1 ]; then
        echo "[ERROR] Invalid number of arguments"
        exit 1
fi
# make sure that $ROOT_DIR is a directory and it was supplied
if [ ! -z "$ROOT_DIR" -a ! -d "$ROOT_DIR" ]; then
        echo "[ERROR] $ROOT_DIR is not a directory"
        exit 1
fi



### Saplib-specific

# install 'color' dependency
echo "[INFO] Installing dependency: 'color'..."
SRC_FILE="$BUILD_DIR/dependencies/color/color"
DST_FILE="$ROOT_DIR/usr/local/bin/color"
cp "$SRC_FILE" "$DST_FILE"
if [ "$?" -ne 0 ]; then
        echo "[EXCEPTION] Failed to copy '$SRC_FILE' to '$DST_FILE'"
        exit 1
fi
chmod 755 $DST_FILE
unset -v SRC_FILE ; unset -v DST_FILE

SRC_FILE="$BUILD_DIR/dependencies/color/color.1"
DST_FILE="$ROOT_DIR/usr/share/man/man1/color.1"
cp "$SRC_FILE" "$DST_FILE"
if [ "$?" -ne 0 ]; then
        echo "[EXCEPTION] Failed to copy '$SRC_FILE' to '$DST_FILE'"
        exit 1
fi
chmod 644 $DST_FILE
echo "[SUCCESS] Installed dependency: 'color'"
unset -v SRC_FILE ; unset -v DST_FILE

# install 'pisces' dependency
echo "[INFO] Installing dependency: 'pisces'..."
cp "$BUILD_DIR"/dependencies/pisces/conf.d/* "$ROOT_DIR"/etc/fish/conf.d/
cp "$BUILD_DIR"/dependencies/pisces/functions/* "$ROOT_DIR"/etc/fish/functions/
echo "[SUCCESS] Installed dependency: 'pisces'"

# modify '/etc/environment'
SRC_FILE="$BUILD_DIR/environment.append"
DST_FILE="$ROOT_DIR/etc/environment"
echo "[INFO] Modifying global config: '$DST_FILE'..."
# check if any '@SAPLING*'-tag is present in '$DST_FILE'
grep '@SAPLING' "$DST_FILE" 1>/dev/null 2>/dev/null
if [ "$?" -ne 0 ]; then
        # append the lines to '$DST_FILE'
        echo "" >> "$DST_FILE"
        cat "$SRC_FILE" >> "$DST_FILE"
        if [ "$?" -ne 0 ]; then
                echo "[EXCEPTION] Failed to append '$SRC_FILE' to '$DST_FILE'"
                exit 1
        fi
fi
echo "[SUCCESS] Modified global config: '$DST_FILE'"
unset -v SRC_FILE ; unset -v DST_FILE

# modify '/etc/bash.bashrc'
SRC_FILE="$BUILD_DIR/bash.bashrc.append"
DST_FILE="$ROOT_DIR/etc/bash.bashrc"
echo "[INFO] Modifying global config: '$DST_FILE'..."
# check if any '@SAPLING*'-tag is present in '$DST_FILE'
grep '@SAPLING' "$DST_FILE" 1>/dev/null 2>/dev/null
if [ "$?" -ne 0 ]; then
        # append the lines to '$DST_FILE'
        echo "" >> "$DST_FILE"
        cat "$SRC_FILE" >> "$DST_FILE"
        if [ "$?" -ne 0 ]; then
                echo "[EXCEPTION] Failed to append '$SRC_FILE' to '$DST_FILE'"
                exit 1
        fi
fi
echo "[SUCCESS] Modified global config: '$DST_FILE'"
unset -v SRC_FILE ; unset -v DST_FILE

# (Re)install Saplib sourcecode
SRC_DIR="$BUILD_DIR/saplib"
DST_PARENT_DIR="$ROOT_DIR/usr/local/lib"
echo "[INFO] Installing saplib source files..."
# clean previous files
rm -rf "$DST_PARENT_DIR"/saplib
cp -r "$SRC_DIR" "$DST_PARENT_DIR"/
if [ "$?" -ne 0 ]; then
        echo "[ERROR] Failed to copy $SRC_DIR to $DST_PARENT_DIR/"
        exit 1
fi
unset -v SRC_DIR ; unset -v DST_PARENT_DIR

# create fish config symlinks
ln -sf /usr/local/lib/saplib/fish/saplib.fish "$ROOT_DIR"/etc/fish/conf.d/saplib.fish

# modify '/etc/xdg/nvim/sysinit.vim'
SRC_FILE="$BUILD_DIR/sysinit.vim.append"
DST_FILE="$ROOT_DIR/etc/xdg/nvim/sysinit.vim"
mkdir -p $(dirname $DST_FILE)
echo "[INFO] Modifying global config: '$DST_FILE'..."
# check if any '@SAPLING*'-tag is present in '$DST_FILE'
grep '@SAPLING' "$DST_FILE" 1>/dev/null 2>/dev/null
if [ "$?" -ne 0 ]; then
        # append the lines to '$DST_FILE'
        echo "" >> "$DST_FILE"
        cat "$SRC_FILE" >> "$DST_FILE"
        if [ "$?" -ne 0 ]; then
                echo "[EXCEPTION] Failed to append '$SRC_FILE' to '$DST_FILE'"
                exit 1
        fi
fi
echo "[SUCCESS] Modified global config: '$DST_FILE'"
unset -v SRC_FILE ; unset -v DST_FILE

if [ -z "$ROOT_DIR" ]; then
        # neovim plugins can only be installed from within a system
        $THIS_DIR/install-nvim-plugins.bash
        if [ "$?" -ne 0 ]; then
            echo "[ERROR] Something went wrong while installing the saplib neovim plugins"
            exit 1
        fi
else
        # cut plugins out of the installed neovimrc
        SRC_FILE="$ROOT_DIR/usr/local/lib/saplib/nvim/saplib.vim"
        SRC_FILE_OLD="$SRC_FILE".old
        mv "$SRC_FILE" "$SRC_FILE_OLD"
        grep --max-count 1 --before-context 999 '^call plug#begin.*$' "$SRC_FILE_OLD" | head -n -1 > "$SRC_FILE"
        grep --max-count 1 --after-context 999 '^call plug#end.*$' "$SRC_FILE_OLD" | tail -n +2 >> "$SRC_FILE"
        rm "$SRC_FILE_OLD"
fi

exit 0
