#!/usr/bin/env bash

# Replaces the saplib folder in the archiso profile with the newest version
# TODO use a better build system...

# this is used to enable relative path usage from within this script's parent dir
THIS_SCRIPT_DIR="$(dirname $(realpath $0))"
# source build config
source "$THIS_SCRIPT_DIR"/build-config
if [ "$?" -ne 0 ]; then
        echo "[ERROR] Failed to source build config."
        exit 1
fi

# update saplib on the archiso profile
info_message "Removing existing saplib files..."
rm -rf "$ARCHISO_PROFILE_DIR"/airootfs/usr/local/lib/saplib

info_message "Updating saplib..."
cp -pr "$SAPLIB_BUILD_DIR"/saplib "$ARCHISO_PROFILE_DIR"/airootfs/usr/local/lib/
if [ "$?" -ne 0 ]; then
        error_message "Failed to copy saplib to archiso profile."
        exit 1
fi

success_message "Saplib was updated."
exit 0
