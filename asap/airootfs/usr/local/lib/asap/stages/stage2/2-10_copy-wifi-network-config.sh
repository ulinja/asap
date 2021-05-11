#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Copies the installation medium's wifi configuration to the new system to allow
# automatic authorization.
# ----------------------------------------------------------------------------- #
# @file    2-10_copy-wifi-network-config.sh
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

info_message "Copying existing wifi config..."

SRC_DIR='/var/lib/iwd'
DST_DIR="/mnt/var/lib"

mkdir -p $DST_DIR
if [ "$?" -ne 0 ]; then
        exception_message "Failed to create '$DST_DIR'"
        exit 1
fi

cp -r "$SRC_DIR" "$DST_DIR"/
if [ "$?" -ne 0 ]; then
        exception_message "Failed to copy '$SRC_FILE' to '$DST_DIR'"
        exit 1
fi

success_message "Exported the wifi configuration to the new system."
exit 0
