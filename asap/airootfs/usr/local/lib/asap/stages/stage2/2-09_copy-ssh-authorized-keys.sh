#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Transfers the installation medium's authorized ssh keys to the new system's
# asap resources directory, for later use in stage3, if they exist.
# The keys will not be copied to '/mnt/root', as ssh access to the root user's
# account is discouraged for security reasons. They will be stored in the asap
# library folder and in stage3 installed to the non-root user, if so desired.
# ----------------------------------------------------------------------------- #
# @file    2-09_copy-ssh-authorized-keys.sh
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

if [ -e /root/.ssh/authorized_keys ]; then
    info_message "Storing authorized ssh keys in the asap library..."

    cp /root/.ssh/authorized_keys /mnt"$ASAP_RESOURCES_DIR"/authorized_keys.append
    if [ "$?" -ne 0 ]; then
            exception_message "Failed to copy authorized_keys"
            exit 1
    fi

    success_message "Stored the ssh keys temporarily."
fi

exit 0
