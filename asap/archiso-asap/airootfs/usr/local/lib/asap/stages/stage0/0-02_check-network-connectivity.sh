#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Ensures that an internet connection is available.
# ----------------------------------------------------------------------------- #
# @file    0-02_check-network-connectivity.sh
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

info_message "Checking network connectivity..."
ping -4 -c 5 archlinux.org 1>/dev/null 2>/dev/null
if [ "$?" -ne 0 ]
then
        error_message 'System does not have an internet connection.'
        warning_message 'Please establish an internet connection before proceeding.'
        exit 1
fi

success_message 'System has internet connection.'
exit 0
