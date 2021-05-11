#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Regenerates the grub configuration file after inserting the sapling splash
# screen.
# ----------------------------------------------------------------------------- #
# @file    3-08_grub-config.sh
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

# set grub background image in /etc/default/grub
# FIXME using hardcoded path. Build the path using $ASAP_RESOURCES_DIR
sed -i 's/^#GRUB_BACKGROUND.*$/GRUB_BACKGROUND=\"\/usr\/local\/lib\/asap\/resources\/splash.png\"/' /etc/default/grub
if [ "$?" -ne 0 ]; then
        warning_message "Failed to set grub background in the grub config file..."
fi

# generate grub config file
# XXX assumes that the boot directory is at '/boot'
info_message "Generating GRUB configuration file..."
grub-mkconfig -o /boot/grub/grub.cfg
if [ "$?" -ne 0 ]; then
        error_message "Failed to generate grub config!"
        warning_message "Aborting..."
        exit 1
fi

success_message "GRUB config generated."

exit 0
