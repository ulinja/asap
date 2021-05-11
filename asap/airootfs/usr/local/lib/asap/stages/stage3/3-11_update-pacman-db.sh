#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Updates the pacman core database.
# ----------------------------------------------------------------------------- #
# @file    3-11_update-pacman-db.sh
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

info_message "Updating pacman db..."

pacman -Fy
if [ "$?" -ne 0 ]; then
        exception_message "Failed to update pacman core db"
        exit 1
fi

success_message "iwd daemon will be active upon reboot."
exit 0
