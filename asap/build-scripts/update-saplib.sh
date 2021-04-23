#!/usr/bin/env bash

# Updates saplib in the archiso profile with the newest version
# TODO use a better build system...

# this is used to enable relative path usage from within this script's parent dir
THIS_SCRIPT_DIR="$(dirname $(realpath $0))"
# source build config
source "$THIS_SCRIPT_DIR"/build-config
if [ "$?" -ne 0 ]; then
        echo "[ERROR] Failed to source build config."
        exit 1
fi

info_message "Updating saplib..."
sudo -u '#1000' $SAPLIB_BUILD_DIR/../install-scripts/install.bash $(realpath $ARCHISO_PROFILE_DIR/airootfs)
if [ "$?" -ne 0 ]; then
        error_message "Failed to update saplib on the archiso profile."
        exit 1
fi

# copy saplib installation folder to the asap resources folder.
# its scripts will get executed in stage3
rm -rf "$ARCHISO_PROFILE_DIR"/airootfs/usr/local/lib/asap/resources/saplib
sudo -u '#1000' mkdir -p "$ARCHISO_PROFILE_DIR"/airootfs/usr/local/lib/asap/resources/saplib
sudo -u '#1000' cp -r "$SAPLIB_BUILD_DIR"/../install-scripts "$ARCHISO_PROFILE_DIR"/airootfs/usr/local/lib/asap/resources/saplib/
if [ "$?" -ne 0 ]; then
        error_message "Failed to copy saplib install-scripts directory to asap resources folder."
        exit 1
fi
sudo -u '#1000' cp -r "$SAPLIB_BUILD_DIR"/../README.md "$ARCHISO_PROFILE_DIR"/airootfs/usr/local/lib/asap/resources/saplib/
if [ "$?" -ne 0 ]; then
        error_message "Failed to copy saplib README.md to asap resources folder."
        exit 1
fi
sudo -u '#1000' cp -r "$SAPLIB_BUILD_DIR" "$ARCHISO_PROFILE_DIR"/airootfs/usr/local/lib/asap/resources/saplib/
if [ "$?" -ne 0 ]; then
        error_message "Failed to copy saplib build directory to asap resources folder."
        exit 1
fi

success_message "Saplib was updated."
exit 0
