#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Modifies the 'useradd' config on the new system, to make fish the default
# login shell for new users.
#
# TODO allow user to choose the default login shell on the new system
# ----------------------------------------------------------------------------- #
# @file    2-12_configure-useradd.sh
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

info_message "Modifiyng the 'useradd' config..."

sed -i 's/SHELL=\/bin\/bash/SHELL=\/bin\/fish/' /mnt/etc/default/useradd
if [ "$?" -ne 0 ]; then
        exception_message "Failed to modify '/mnt/etc/default/useradd'"
        exit 1
fi

success_message "Modified the 'useradd' config."
exit 0
