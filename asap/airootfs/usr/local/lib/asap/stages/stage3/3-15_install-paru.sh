#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# This script installs paru, an AUR package manager, on the local machine.
# Should be run by the non-root admin user. Must not be run by root.
# XXX Assumes that a user with the UID 1000 has been created.
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

# check if a user with UID 1000 exists
grep 'x:1000:' /etc/passwd 1>/dev/null 2>/dev/null
if [ "$?" -ne 0 ]; then
    error_message "No user found for UID 1000. Have you created a non-root user?"
    exit 1
fi

# get user 1000's username
NON_ROOT_USER="$(getent passwd "1000" | cut -d ':' -f 1)"

ORIG_DIR="$(pwd)"
cd /home/"$NON_ROOT_USER"
if [ "$?" -ne 0 ]; then
    error_message "Directory not found: '/home/$NON_ROOT_USER'."
    exit 1
fi

info_message "Downloading paru..."
sudo -u "$NON_ROOT_USER" git clone 'https://aur.archlinux.org/paru.git'
if [ "$?" -ne 0 ]; then
        error_message "Failed to clone paru repository."
        exit 1
fi

cd paru || exit 1
info_message "Installing paru..."
sudo -u "$NON_ROOT_USER" makepkg -scirf
if [ "$?" -ne 0 ]; then
        exception_message "Failed to install paru."
        exit 1
fi
# remove cloned repo folder
cd ..
rm -rf paru

cd "$ORIG_DIR"

success_message 'paru has been installed.'
