#!/usr/bin/env bash

# Cleans the build directory of any existing files

# this is used to enable relative path usage from within this script's parent dir
THIS_SCRIPT_DIR="$(dirname $(realpath $0))"
# source build config
source "$THIS_SCRIPT_DIR"/build-config
if [ "$?" -ne 0 ]; then
        echo "[ERROR] Failed to source build config."
        exit 1
fi

# remove all files in the build dir
rm -vf "$ARCHISO_OUTPUT_DIR"/*
