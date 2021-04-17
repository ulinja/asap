#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Modifies the login shell for the root user on the new system.
# ----------------------------------------------------------------------------- #
# @file    2-12_modify-root-login-shell.sh
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

info_message "Setting the root login shell..."

sed -i 's/\/root:\/bin\/bash/\/root:\/bin\/fish/' /mnt/etc/passwd
if [ "$?" -ne 0 ]; then
        exception_message "Failed to modify '/mnt/etc/passwd'"
        exit 1
fi

success_message "Set the root login shell."
exit 0
