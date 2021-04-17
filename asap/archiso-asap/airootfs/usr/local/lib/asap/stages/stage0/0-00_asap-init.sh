#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Sets the correct permissions for all asap scripts and creates resources like
# the asap working direcotry for future use in other scripts.
# ----------------------------------------------------------------------------- #
# @file    0-00_sapling-init.sh
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

info_message "Initializing asap..."

# make stage wrapper scripts executable
for scriptfile in /usr/local/bin/asap_* ; do
        chmod 740 "$scriptfile"
done

# make setup scripts executable
for scriptfile in "$ASAP_SCRIPTS_DIR"/stage*/*.sh ; do
        chmod 740 "$scriptfile"
done

# currently the only resource script which needs to be executable
chmod 740 "$ASAP_RESOURCES_DIR"/download-pacman-mirrorlist.py

# Create global working directory
mkdir "$ASAP_WORKING_DIR"
if [ "$?" -ne 0 ]
then
        exception_message "Failed to create sapling working directory at $ASAP_WORKING_DIR"
        warning_message "Aborting!"
        exit 1
else
        debug_message "Sapling working directory created at $ASAP_WORKING_DIR"
fi

# Create global checkpoint file
touch "$ASAP_CHECKPOINTFILE"
if [ "$?" -ne 0 ]
then
        exception_message "Failed to create sapling checkpoint file at $ASAP_CHECKPOINTFILE"
        warning_message "Aborting!"
        exit 1
else
        debug_message "Sapling checkpoint file created at $ASAP_CHECKPOINTFILE"
fi

success_message "asap was initialized."
exit 0
