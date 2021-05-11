#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Ensures that the live medium is booted in UEFI mode.
# ----------------------------------------------------------------------------- #
# @file    0-01_check-uefi-mode.sh
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

ls /sys/firmware/efi/efivars 1>/dev/null 2>/dev/null
if [ "$?" -ne 0 ]
then
        error_message 'System is not in UEFI mode! Please reboot in UEFI mode.'
        warning_message 'Aborting!'
        exit 1
fi

success_message 'Live medium is in UEFI mode.'
exit 0
