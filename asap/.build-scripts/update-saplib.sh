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
$SAPLIB_BUILD_DIR/../install_scripts/install.bash $(realpath $ARCHISO_PROFILE_DIR/airootfs)
if [ "$?" -ne 0 ]; then
        error_message "Failed to update saplib on the archiso profile."
        exit 1
fi

success_message "Saplib was updated."
exit 0
