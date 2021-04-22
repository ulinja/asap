#!/usr/bin/env bash

# Copies a public SSH key to the archiso profile to allow ssh access to the installation medium.

# this is used to enable relative path usage from within this script's parent dir
THIS_SCRIPT_DIR="$(dirname $(realpath $0))"
# source build config
source "$THIS_SCRIPT_DIR"/build-config
if [ "$?" -ne 0 ]; then
        echo "[ERROR] Failed to source build config."
        exit 1
fi

info_message "You can embed your public SSH key into the ISO to allow SSH access to the installation medium."
prompt_yes_or_no "Do you want to embed an authorized SSH key on the ISO?"
if [ "$?" -ne 0 ]; then
        info_message "Skipping ssh public key integration."
        exit 0
fi

prompt_enter_to_continue "Please select your PUBLIC ssh key, which will be used to authenticate access to the installation medium."
PATH_TO_PUBKEY=$(find $(find / -type d -name .ssh 2>/dev/null) -type f | fzf)

# make sure its not a private key...
grep -i 'PRIVATE' $PATH_TO_PUBKEY 1>/dev/null 2>/dev/null
if [ "$?" -eq 0 ]; then
        error_message "You provided a PRIVATE key. You absolute Dingus -.-"
        exit 1
fi

# copy to authorized keys on the ISO
cat $PATH_TO_PUBKEY > "$ARCHISO_PROFILE_DIR/airootfs/root/.ssh/authorized_keys"

success_message "Your ssh key was imported."
exit 0
