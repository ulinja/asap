#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Copies the asap setup scripts for stage3 and above to the new system.
#
# TODO delete previous stages
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

info_message "Copying asap to the new system..."

# copy asap library
cp -pr /usr/local/lib/asap /mnt/usr/local/lib/
mkdir -p /mnt/usr/local/bin
for scriptfile in /usr/local/bin/asap_* ; do
        cp -p "$scriptfile" /mnt"$scriptfile"
done

# copy saplib bash library
cp -pr /usr/local/lib/saplib /mnt/usr/local/lib/
# copy color
cp -pr /usr/local/bin/color /mnt/usr/local/bin/
chmod 755 /mnt/usr/local/bin/color

success_message "Installed asap on the new system."
exit 0
