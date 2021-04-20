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

# check if user is root
if [ "$(id -u)" -ne 0 ]; then
        echo "[ERROR] You must have root privileges for the installation."
        exit 1
fi

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



### nvim-specific

# modify '/etc/xdg/nvim/sysinit.vim'
SRC_FILE="$BUILD_DIR/sysinit.vim.append"
DST_FILE="$ROOT_DIR/etc/xdg/nvim/sysinit.vim"
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

# install vim-plug
curl -fLo /etc/xdg/nvim/autoload/plug.vim --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to download vim-plug"
    exit 1
fi

# install python support for neovim
package='pynvim'
python3 -m pip install --upgrade $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package

# install neovim deoplete dependency
package='msgpack'
python3 -m pip install --upgrade $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package



### Ale linting engines

package='bashate'
python3 -m pip install --upgrade $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package

package='pycodestyle'
python3 -m pip install --upgrade $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package

package='autopep8 '
python3 -m pip install --upgrade $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package

package='mypy'
python3 -m pip install --upgrade $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package

package='pyflakes'
python3 -m pip install --upgrade $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package


# pacman packages

package='shellcheck'
pacman -Sy --noconfirm --quiet $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package

package='desktop-file-utils'
pacman -Sy --noconfirm --quiet $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package


## npm packages

package='bash-language-server'
npm i -g $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package

package='fixjson '
npm i -g $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package

package='sql-lint'
npm i -g $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package

package='prettier'
npm install --save-dev --save-exact $package
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to install $package"
    exit 1
fi
unset -v package



### Finalize

# run :PlugInstall
nvim -c ":PlugInstall"

echo "[SUCCESS] Saplib was installed."
echo "[INFO] Please log out or reboot to start using saplib."
exit 0
