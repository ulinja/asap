#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# NOT IN USE CURRENTLY
# TODO implement this using '/etc/skel'
# Creates the skeleton folder structure on the system.
# ----------------------------------------------------------------------------- #
# @file    filesystem-init.sh
# @version 1.0
# @author  cybork
# @email   
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

##### source the necessary libraries
libraries=(
        "$SAPLIB_BASH"
        "$ASAP_CONFIG"
        "$ASAP_FUNCTIONS"
)
for lib in "${libraries[@]}"; do
        source $lib
        if [ "$?" -ne 0 ]; then
                echo "[EXCEPTION] Failed to source $lib."
                exit 1
        fi
done

################################# BEGIN SCRIPT ##################################

directories=(
    "$HOME/.config"
    "$HOME/.credentials/keyfiles"
    "$HOME/.dotfiles"
    "$HOME/.icons"
    "$HOME/.scripts"
    "$HOME/.scripts/backup"
    "$HOME/.scripts/launch-scripts"
    "$HOME/.scripts/mount"
    "$HOME/.scripts/printing"
    "$HOME/.scripts/utilities"
    "$HOME/.themes"
    "$HOME/documents"
    "$HOME/downloads"
    "$HOME/media"
    "$HOME/media/audio"
    "$HOME/media/ebooks"
    "$HOME/media/pictures"
    "$HOME/media/pictures/screenshots"
    "$HOME/media/pictures/wallpapers"
    "$HOME/media/software"
    "$HOME/media/software/git"
    "$HOME/media/videos"
    "$HOME/projects"
    "$HOME/projects/arduino"
    "$HOME/projects/bash"
    "$HOME/projects/c"
    "$HOME/projects/general"
    "$HOME/projects/java"
    "$HOME/projects/python"
    "$HOME/projects/websites"
    "$HOME/shared/public/JuliMediaServer"
    "$HOME/shared/public/WaldhimmelCloud"
    "$HOME/shared/public/WolleMovieDB"
    "$HOME/uni"
    )

for dir in "${directories[@]}"
do
    mkdir -p -v $dir
done
