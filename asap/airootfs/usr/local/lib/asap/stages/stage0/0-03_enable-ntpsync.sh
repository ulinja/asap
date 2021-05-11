#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Enables NTP synchronization for the live environment.
# ----------------------------------------------------------------------------- #
# @file    0-03_enable-ntpsync.sh
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

timedatectl set-ntp true 1>/dev/null 2>/dev/null
if [ "$?" -ne 0 ]
then
        error_message 'Failed to enable NTP synchronization.'
        warning_message 'Aborting.'
        exit 1
fi

# FIXME suppress journalctl messages after running timedatectl
# workaround is to just wait until they all printed and then echo a newline. not even this works reliably
sleep 4
echo ""

success_message 'NTP synchronization enabled.'
info_message "Run 'timedatectl status' for more information."
exit 0
