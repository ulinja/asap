#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# This script installs paru on the local machine.
# Should be run by the non-root admin user.
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

info_message "Downloading paru..."
git clone 'https://aur.archlinux.org/paru.git'
if [ "$?" -ne 0 ]; then
        error_message "Failed to clone paru repository."
        exit 1
fi

cd paru || exit 1

info_message "Installing paru..."
makepkg -scirf
if [ "$?" -ne 0 ]; then
        exception_message "Failed to install paru."
        exit 1
fi

# remove cloned repo folder
cd ..
rm -rvf paru

# TODO copy paru config file

# update paru using paru (yo dawg i heard you like paru)
paru -Sy paru
if [ "$?" -ne 0 ]; then
        exception_message "Failed to update paru."
        exit 1
fi

success_message 'paru has been installed.'
