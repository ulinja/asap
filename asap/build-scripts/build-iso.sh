#!/usr/bin/env bash

# Builds the custom archiso into the build directory using archiso.
# TODO use a better build system...

# this is used to enable relative path usage from within this script's parent dir
THIS_SCRIPT_DIR="$(dirname $(realpath $0))"
# source build config
source "$THIS_SCRIPT_DIR"/build-config
if [ "$?" -ne 0 ]; then
        echo "[ERROR] Failed to source build config."
        exit 1
fi

# clean previous builds
info_message "Cleaning build directory..."
"$THIS_SCRIPT_DIR"/clean-iso.sh

# update saplib on the archiso profile
"$THIS_SCRIPT_DIR"/update-saplib.sh || exit 1

# add and configure a wifi pre-shared key to the iso
$THIS_SCRIPT_DIR/embed-wpa2-psk.sh
if [ "$?" -ne 0 ]; then
        exit 1
fi

# add an ssh authorized_key to the iso
$THIS_SCRIPT_DIR/embed-ssh-authorized-key.sh
if [ "$?" -ne 0 ]; then
        exit 1
fi

# begin build and measure how long it takes
info_message "Beginning ISO build..."
START_TIME="$(date +%s)"
mkdir -vp "$ARCHISO_WORKING_DIR"
mkarchiso -v -w "$ARCHISO_WORKING_DIR" -o "$ARCHISO_OUTPUT_DIR" "$ARCHISO_PROFILE_DIR"/ ; exit_status="$?"
END_TIME="$(date +%s)"
ELAPSED_TIME="$(( END_TIME - START_TIME ))"

if [ "$exit_status" -ne 0 ]
then
        error_message "Build failed after $ELAPSED_TIME seconds!"
        warning_message "Make sure there are no mount binds in $ARCHISO_WORKING_DIR before deleting it!"
        info_message "Run findmnt to find out."
        exit 1
fi

info_message "Removing $ARCHISO_WORKING_DIR"
rm -rf "$ARCHISO_WORKING_DIR"

# change owner of the iso
chown 1000:1000 "$ARCHISO_OUTPUT_DIR"/*

success_message "Build completed in $ELAPSED_TIME seconds."

# XXX remove secrets to avoid pushing them to git!
$THIS_SCRIPT_DIR/remove-wpa2-psk.sh
if [ "$?" -ne 0 ]; then
        error_message "FAILED TO REMOVE WPA2 SECRETS FROM 'airootfs/var/lib/iwd'"
        critical_warning_message "DO NOT INDEX WIFI PASSWORD on git."
        exit 1
fi

$THIS_SCRIPT_DIR/remove-ssh-authorized-key.sh
if [ "$?" -ne 0 ]; then
        error_message "FAILED TO REMOVE SSH KEY FROM 'airootfs/root/.ssh'"
        warning_message "Avoid indexing your ssh public key on git."
        exit 1
fi

exit 0
