#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Parses the currently mounted devices list and generates /etc/fstab on the new
# system using genfstab.
# ----------------------------------------------------------------------------- #
# @file    2-04_genfstab.sh
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

DST_FILE="/mnt/etc/fstab"

info_message "Generating filesystem table..."
genfstab -U /mnt >> "$DST_FILE" ; exit_status="$?"
if [ "$exit_status" -ne 0 ]; then
        error_message "Failed to generate fstab!"
        warning_message "Aborting..."
        exit 1
fi

success_message "Filesystem table was generated at $DST_FILE"
prompt_yes_or_no "Would you like to review the generated fstab?"
if [ "$?" -eq 0 ]; then
        "$EDITOR" "$DST_FILE"
fi

exit 0
