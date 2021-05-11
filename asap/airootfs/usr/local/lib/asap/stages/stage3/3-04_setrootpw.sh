#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Makes the user set the root password on the new system.
# ----------------------------------------------------------------------------- #
# @file    3-04_setrootpw.sh
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

info_message "Please set a new password for the root user now:"
passwd root
if [ "$?" -ne 0 ]; then
        error_message "Failed to set root user password!"
        warning_message "Aborting..."
        exit 1
fi

success_message "root password was set."
exit 0
