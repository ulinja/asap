#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Copies the asap setup scripts for stage3 and above to the new system.
# ----------------------------------------------------------------------------- #
# @file    2-06_install-asap.sh
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
# TODO delete older stages

info_message "Copying asap to the new system..."

# copy asap library stage3 and above
cp -pr /usr/local/lib/asap /mnt/usr/local/lib/
mkdir -p /mnt/usr/local/bin
for scriptfile in /usr/local/bin/asap_* ; do
        cp -p "$scriptfile" /mnt"$scriptfile"
done

success_message "Installed asap on the new system."
exit 0
