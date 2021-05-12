#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Installs the saplib setupfiles on the new system.
# ----------------------------------------------------------------------------- #
# @file    2-06_install-asap.sh
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

info_message "Fetching saplib setup files..."

rm -rf /mnt/usr/local/lib/asap/resources/saplib
git clone 'https://github.com/ulinja/saplib.git' /mnt/usr/local/lib/asap/resources/saplib
if [ "$?" -ne 0 ]; then
    error_message "Failed to fetch saplib setupfiles."
    warning_message "Aborting..."
    exit 1
fi

success_message "Fetched saplib setup files to the new system."
exit 0
