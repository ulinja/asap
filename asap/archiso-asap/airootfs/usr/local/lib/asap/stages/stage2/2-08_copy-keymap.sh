#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Copies the keymap configuration to the new system.
# ----------------------------------------------------------------------------- #
# @file    2-08_copy-keymap.sh
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

info_message "Copying keymap configuration to the new system..."

# copy persistent keymap
debug_message "Copying keymap information"
cp "/etc/vconsole.conf" "/mnt/etc/"
if [ "$?" -ne 0 ]; then
        exception_message "Failed to copy vconsole.conf to new system!"
        warning_message "Aborting..."
        exit 1
else
        unset exit_status
fi

success_message "Installed keymap configuration on the new system."
exit 0
