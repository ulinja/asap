#!/usr/bin/env bash

# Writes an ISO image to the block device specified as the first argument.
# USE WITH CAUTION this is a dangerous script

# Dependencies: fzf

# this is used to enable relative path usage from within this script's parent dir
THIS_SCRIPT_DIR="$(dirname $(realpath $0))"
# source build config
source "$THIS_SCRIPT_DIR"/build-config
if [ "$?" -ne 0 ]; then
        echo "[ERROR] Failed to source build config."
        exit 1
fi

# check number of arguments
if [ "$#" -ne 1 ]; then
        error_message "Expected exactly one argument."
        exit 1
fi

# check if argument is a block device
if [[ ! $(file $1) =~ ^.*block.special.*$ ]]; then
        error_message "$1 does not seem to be a block device!"
        exit 1
fi

# check if there are files in the iso-builds folder
if [ "$(ls $ARCHISO_OUTPUT_DIR | wc -l)" -lt 1 ]; then
        error_message "No files in '$ARCHISO_OUTPUT_DIR'. Build an ISO before proceeding."
        exit 1
fi

# select input iso file. use fzf selector if there are multiple images
orig_dir="$(pwd)"
cd $ARCHISO_OUTPUT_DIR
INPUT_FILE="$(realpath $(fzf -1))"
cd "$orig_dir"
unset orig_dir

# check if output device has partitions on it
if [ "$(lsblk $1 | wc -l)" -gt 2 ];then
        error_message "$1 has partitions on it! Please remove them before writing an iso image to it."
        exit 1
fi

warning_message "You are about to write the image '$(basename $INPUT_FILE)' to '$1'."
warning_message "Data on '$1' will be overwritten irrevocably!"
prompt_yes_or_no "ARE YOU SURE???"
if [ "$?" -ne 0 ];then
        info_message "Aborting..."
        exit 0
fi

# begin writing image
START_TIME="$(date +%s)"
dd bs=4M if="$INPUT_FILE" of="$1" status=progress oflag=sync
exit_status="$?"
END_TIME="$(date +%s)"
ELAPSED_TIME="$(( END_TIME - START_TIME ))"

if [ "$exit_status" -ne 0 ]; then
        error_message "Failed to write image after $ELAPSED_TIME seconds."
        exit 1
fi

echo "[SUCCESS] Wrote image in $ELAPSED_TIME seconds."
