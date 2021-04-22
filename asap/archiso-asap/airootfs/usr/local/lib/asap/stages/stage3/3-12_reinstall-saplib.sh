#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Reinstalls saplib, including its neovim plugins.
# ----------------------------------------------------------------------------- #
# @file    3-12_reinstall-saplib.sh
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

info_message "Resinstalling Saplib..."

"$ASAP_RESOURCES_DIR"/saplib/install-scripts/install.bash
if [ "$?" -ne 0 ]; then
        exception_message "Failed to reinstall saplib."
        exit 1
fi

success_message "Saplib installation complete. Log out or reboot for changes to take effect."
exit 0
