#!/usr/bin/env bash

# Removes all WPA2 WiFi pre-shared key from the archiso profile.

# this is used to enable relative path usage from within this script's parent dir
THIS_SCRIPT_DIR="$(dirname $(realpath $0))"
# source build config
source "$THIS_SCRIPT_DIR"/build-config
if [ "$?" -ne 0 ]; then
        echo "[ERROR] Failed to source build config."
        exit 1
fi

info_message "Removing WPA2 secrets from archiso profile..."

rm -f "$ARCHISO_PROFILE_DIR"/airootfs/var/lib/iwd/*

success_message "Removed WPA2 secrets."
exit 0
