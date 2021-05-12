#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Enables the systemd ssh service on the new system if the user wishes to do so.
#
# TODO skip if '/home/$USER/.ssh/authorized_keys' does not exist
# ----------------------------------------------------------------------------- #
# @file    3-09_enable-ssh-daemon.sh
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
# TODO harden the sshd config!!!

prompt_yes_or_no "Would you like to enable the ssh daemon to allow for remote access to the new system?"
if [ "$?" -ne 0 ]; then
        info_message "Leaving ssh daemon disabled."
        exit 0
fi

systemctl enable sshd.service
if [ "$?" -ne 0 ]; then
        exception_message "Failed to enable 'sshd.service'"
        exit 1
fi

success_message "ssh daemon will be active upon reboot."
exit 0
