#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Installs the grub bootloader to the new system.
# XXX Assumes that the boot directory is at '/boot'
# ----------------------------------------------------------------------------- #
# @file    3-06_grub-install.sh
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
# TODO verify that the boot directory is indeed at '/boot'

# install grub
info_message "Installing GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
if [ "$?" -ne 0 ]; then
        error_message "Failed to install grub!"
        warning_message "Aborting..."
        exit 1
fi

success_message "GRUB was installed."

exit 0
