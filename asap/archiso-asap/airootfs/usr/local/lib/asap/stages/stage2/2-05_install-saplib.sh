#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Installs the saplib library to the new system.
# ----------------------------------------------------------------------------- #
# @file    2-05_install-saplib.sh
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

info_message "Installing saplib..."

# execute the saplib install script in chroot mode

"$ASAP_RESOURCES_DIR"/saplib/install-scripts/install.bash /mnt
if [ "$?" -ne 0 ]; then
        exception_message "Failed to install saplib."
        exit 1
fi

success_message "Finished installing saplib."
exit 0
