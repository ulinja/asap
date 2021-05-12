#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Regenerates all initramfs images.
# ----------------------------------------------------------------------------- #
# @file    3-07_generate-initramfs-image.sh
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

info_message "Regenerating initramfs images..."
mkinitcpio -P
if [ "$?" -ne 0 ]; then
        error_message "Failed to regenerate initramfs images!"
        warning_message "Aborting..."
        exit 1
fi

success_message "Initramfs images rebuilt."
exit 0
