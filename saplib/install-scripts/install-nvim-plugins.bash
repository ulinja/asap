#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Installs the vim-plug plugin manager for neovim.
# Installs the necessary dependencies for saplib neovim to work as intended.
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

echo "[INFO] Installing nvim plugins..."

# install vim-plug
curl -fLo /etc/xdg/nvim/autoload/plug.vim --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
if [ "$?" -ne 0 ]; then
    echo "[ERROR] failed to download vim-plug"
    exit 1
fi


python_packages=(
        'pynvim'        # python support for neovim
        'msgpack'       # deoplete dependency
        'jedi'          # deoplete dependency for python
        'bashate'       # (ale) bash language server
        'pycodestyle'   # (ale) python linter
        'autopep8'      # (ale) python linter
        'mypy'          # (ale) python linter for static typing
        'pyflakes'      # (ale) python linter
)
for package in "${python_packages[@]}"
do
        python3 -m pip install --upgrade "$package"
        if [ "$?" -ne 0 ]; then
            echo "[ERROR] failed to install $package"
            exit 1
        fi
done


pacman_packages=(
        'shellcheck'            # (ale) bash linter
        'desktop-file-utils'    # (ale) XDG-Desktop file linter
)
for package in "${pacman_packages[@]}"
do
        pacman -Sy --noconfirm --quiet $package
        if [ "$?" -ne 0 ]; then
            echo "[ERROR] failed to install $package"
            exit 1
        fi
done


npm_packages=(
        'neovim'
        'bash-language-server'
        'fixjson'
        #'sql-lint'  # seems to be broken
        'prettier'
)
for package in "${npm_packages[@]}"
do
        npm install -g $package
        if [ "$?" -ne 0 ]; then
            echo "[ERROR] failed to install $package"
            exit 1
        fi
done


# install plugins using vim-plug
nvim -c ":PlugInstall" -c ":qa"

echo "[SUCCESS] Neovim plugins were installed."
exit 0
