#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Modifies the sudoers file to allow users of the wheel group to use sudo.
# XXX Does not use 'visudo', not sure if this is safe...
# ----------------------------------------------------------------------------- #
# @file    3-05_modify-sudoers-file.sh
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

info_message "Modifying sudoers file to allow access to 'wheel' group members..."
sed -i 's/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers
if [ "$?" -ne 0 ]; then
        error_message "Failed to modify sudoers file."
        exit 1
fi

success_message "Modified sudoers file."
exit 0
