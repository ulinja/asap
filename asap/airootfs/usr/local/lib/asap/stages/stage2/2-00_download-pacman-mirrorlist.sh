#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Download an updated and ranked-by-downloadspeed mirrorlist to the sapling
# working directory, using the download-pacman-mirrorlist.py script.
#
# TODO fix the python script to handle cmdline arguments and specify ouput dir
# TODO improve user interaction to remove unwanted target countries
# ----------------------------------------------------------------------------- #
# @file    2-00_download-pacman-mirrorlist.sh
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

info_message "I am about to download a fresh pacman mirrorlist."
info_message "By default, mirrors from all countries will be added."
# prompt the user if he wants to modify the mirrors to download
prompt_yes_or_no "Would you like to modify the default?"
if [ "$?" -eq 0 ]; then
        "$EDITOR" "$ASAP_RESOURCES_DIR"/download-pacman-mirrorlist.py
fi

info_message "Updating the pacman mirrorlist..."
# download the pacman mirrorlist to the sapling working directory
# workaround for a shitty python script is to cd into asap working dir to
# execute and then cd back into the original cwd
orig_dir="$(pwd)"
cd "$ASAP_WORKING_DIR"

python "$ASAP_RESOURCES_DIR/download-pacman-mirrorlist.py"
if [ "$?" -ne 0 ]; then
        error_message "Failed to download pacman mirrorlist!"
        warning_message "Aborting..."
        cd "$orig_dir"
        exit 1
fi

cd "$orig_dir"
success_message "Updated the mirrorlist."
exit 0
