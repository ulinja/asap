#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# This script installs yay on the local machine.
# Should be run by the non-root admin user.
# TODO install paru instead of yay???
# ----------------------------------------------------------------------------- #
# @file    3-00_set-timezone.sh
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

# make sure user is not root
if [ $(id -u) -eq 0 ]
then
        error_message 'Do not run the installation as root!'
        exit 1
fi

info_message "Downloading yay..."
git clone https://aur.archlinux.org/yay.git
if [ "$?" -ne 0 ]; then
        error_message "Failed to clone yay repository."
        exit 1
fi

cd yay || exit 1

info_message "Installing yay..."
makepkg -scirf
if [ "$?" -ne 0 ]; then
        exception_message "Failed to install yay."
        exit 1
fi

# remove cloned repo folder
cd ..
rm -rvf yay

# TODO copy yay config file

# update yay using yay (yo dawg i heard you like yay)
yay -S yay
if [ "$?" -ne 0 ]; then
        exception_message "Failed to update yay."
        exit 1
fi

success_message 'Yay has been installed.'
