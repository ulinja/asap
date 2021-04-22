#!/usr/bin/env bash

# Removes the authorized keys file from the archiso profile.

# this is used to enable relative path usage from within this script's parent dir
THIS_SCRIPT_DIR="$(dirname $(realpath $0))"
# source build config
source "$THIS_SCRIPT_DIR"/build-config
if [ "$?" -ne 0 ]; then
        echo "[ERROR] Failed to source build config."
        exit 1
fi

info_message "Removing ssh key from archiso profile..."

# copy to authorized keys on the ISO
rm -f "$ARCHISO_PROFILE_DIR"/airootfs/root/.ssh/authorized_keys

success_message "Removed the authorized key from the archiso profile."
exit 0
