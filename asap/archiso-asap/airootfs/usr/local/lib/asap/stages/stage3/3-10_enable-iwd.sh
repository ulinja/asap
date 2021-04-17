#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Enables the systemd iwd service on the new system if the user wishes to do so.
# ----------------------------------------------------------------------------- #
# @file    3-10_enable-iwd.sh
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

prompt_yes_or_no "Would you like to enable automatic WiFi access on the new system using iwd?"
if [ "$?" -ne 0 ]; then
        info_message "Leaving iwd daemon disabled."
        exit 0
fi

systemctl enable iwd.service
if [ "$?" -ne 0 ]; then
        exception_message "Failed to enable 'iwd.service'"
        exit 1
fi

success_message "iwd daemon will be active upon reboot."
exit 0
