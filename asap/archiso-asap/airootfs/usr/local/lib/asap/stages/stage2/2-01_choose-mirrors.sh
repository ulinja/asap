#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Prompts the user to edit the previously generated mirrorlist and replaces
# the arch linux default mirrorlist at /etc/pacman.d/mirrorlist.
# ----------------------------------------------------------------------------- #
# @file    2-01_choose-mirrors.sh
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
# TODO make sure that some mirrors were indeed uncommented by the user

SRC_FILE="$ASAP_WORKING_DIR/mirrorlist"
DST_FILE="/etc/pacman.d/mirrorlist"

# Check if source file exists
if [ ! -f "$SRC_FILE" ]; then
        exception_message "Cannot access $SRC_FILE"
        warning_message "Aborting..."
        exit 1
fi

prompt_enter_to_continue "Please uncomment all pacman mirrors you wish to use:"
# open mirrorlist in editor
"$EDITOR" "$SRC_FILE"

info_message "Applying mirrorlist..."
mv -v -b --suffix='.defaultbackup' "$SRC_FILE" "$DST_FILE"
if [ "$?" -ne 0 ]; then
        exception_message "Failed to apply mirrorlist!"
        warning_message "Aborting..."
        exit 1
fi

success_message "Mirrorlist was set."
exit 0
