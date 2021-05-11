#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Synchronizes the system and hardware clocks.
# ----------------------------------------------------------------------------- #
# @file    3-01_sync-hwclock.sh
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

info_message "Synchronizing hardware clock..."

hwclock --systohc
if [ "$?" -ne 0 ]; then
        error_message "Failed to sync hwclock!"
        warning_message "Aborting..."
        exit 1
fi

success_message "Synchronized the hardware clock."
exit 0
