#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Sets the correct timezone.
# XXX Currently hardcoded to Europe/Berlin
# ----------------------------------------------------------------------------- #
# @file    3-00_set-timezone.sh
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

info_message "Setting the timezone..."

# set timezone to Europe/Berlin
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
if [ "$?" -ne 0 ]; then
        error_message "Failed to set the timezone!"
        warning_message "Aborting..."
        exit 1
fi

success_message "Set the timezone."
exit 0
