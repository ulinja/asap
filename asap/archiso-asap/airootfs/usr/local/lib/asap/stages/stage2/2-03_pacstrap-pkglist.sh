#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Runs pactrap using the previously generated packagelist.
# ----------------------------------------------------------------------------- #
# @file    2-03_pacstrap-pkglist.sh
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

INFILE="$ASAP_WORKING_DIR/asap-packagelist.pac"
PACSTRAP_DEST_DIR='/mnt'

# check if packagelist exists
if [ ! -r "$INFILE" ]; then
        exception_message "Could not access $INFILE!"
        warning_message "Aborting..."
        exit 1
fi

warning_message "You have chosen the follwing packages:"
cat "$INFILE"
echo ""
prompt_yes_or_no "I will now pacstrap the new system with these packages. Proceed?"
if [ "$?" -ne 0 ]; then
        info_message "Exiting."
        exit 0
fi

info_message "Pacstrapping the new system to $PACSTRAP_DEST_DIR"
xargs -a "$INFILE" pacstrap "$PACSTRAP_DEST_DIR" ; exit_status="$?"
if [ "$exit_status" -ne 0 ]; then
        error_message "Pacstrap failed."
        warning_message "Aborting..."
        exit 1
fi

success_message "Pacstrap completed."
exit 0
