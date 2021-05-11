#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Initializes, populates and refreshes the pacman gpg keyring.
# See 'https://wiki.archlinux.org/index.php/Pacman/Package_signing' for more
# information.
# ----------------------------------------------------------------------------- #
# @file    3-05_init-gpg-keys.sh
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

info_message "We will initialize the pacman keyring now."

# init pacman key
info_message 'Inititalizing pacman keyring...'
pacman-key --init
if [ "$?" -ne 0 ]; then
        error_message 'Failed to initalize pacman keyring!'
        warning_message 'Aborting...'
        exit 1
fi

# populate pacman key
info_message 'Populating pacman keyring...'
pacman-key --populate archlinux
if [ "$?" -ne 0 ]; then
        error_message 'Failed to populate pacman keyring!'
        warning_message 'Aborting...'
        exit 1
fi

# refresh pacman keys
info_message 'About to refresh the pacman keyring.'
# warn the user that this step takes quite a while
warning_message "This will take a while!"
prompt_yes_or_no "Do you want to skip refreshing the pacman keyring? (not reccommended)"
if [ "$?" -eq 3 ]; then
        pacman-key --refresh-keys
        if [ "$?" -ne 0 ]; then
                error_message 'Failed to refresh pacman keyring!'
                warning_message 'Aborting...'
                exit 1
        fi
fi

success_message "Pacman keyring was initialized."
exit 0
