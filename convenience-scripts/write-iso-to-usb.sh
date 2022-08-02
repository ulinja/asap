#!/usr/bin/env bash

# Writes an ISO image to the block device specified as the first argument.
# USE WITH CAUTION this is a dangerous script
THIS_DIR=$(dirname $(realpath $0))
BUILD_DIR="$THIS_DIR/../build"

function prompt_yes_or_no () {
        # Prints all passed arguments prepended with '[INPUT] ' and appended
        # with ' [y/n] '. (The arguments should be a queestion)
        # Returns 0 if user typed 'y' or 'Y'.
        # Returns 3 if user typed 'n' or 'N'.
        # Returns 1 for everything else (invalid user input)

        printf "[INPUT] $@ [y/n] "
        read user_input

        if [[ $user_input =~ ^[yY]$ ]]; then
                return 0
        elif [[ $user_input =~ ^[nN]$ ]]; then
                return 3
        else
                return 1
        fi
}

# make sure user is root
if [ "$(id -u)" -ne 0 ]; then
        echo "[ERROR] You must have root privileges to run this script."
        exit 1
fi

# check number of arguments
if [ "$#" -ne 1 ]; then
        echo "[ERROR] Expected exactly one argument!"
        exit 1
fi

# check if argument is a block device
if [[ ! $(file $1) =~ ^.*block.special.*$ ]]; then
        echo "[ERROR] $1 is not a block device!"
        exit 1
fi

# check if there are files in the iso-builds folder
if [ "$(ls $BUILD_DIR | wc -l)" -lt 1 ]; then
        echo "[ERROR] No files in '$BUILD_DIR'. Build an ISO before proceeding."
        exit 1
fi

# select input iso file. use fzf selector if there are multiple images
ORIG_DIR="$(pwd)"
cd $BUILD_DIR
INPUT_FILE="$(realpath $(fzf -1))"
cd "$ORIG_DIR"
unset -v ORIG_DIR

# check if output device has partitions on it
if [ "$(lsblk $1 | wc -l)" -gt 2 ];then
        echo "[ERROR] $1 has partitions on it! Please remove them before writing an iso image to it."
        exit 1
fi

echo "[WARNING] You are about to write the image '$(basename $INPUT_FILE)' to '$1'."
echo "[WARNING] Data on '$1' will be overwritten irrevocably!"
prompt_yes_or_no "ARE YOU SURE???"
if [ "$?" -ne 0 ];then
        echo "[INFO] Aborting..."
        exit 0
fi

# begin writing image
START_TIME="$(date +%s)"
dd bs=4M if="$INPUT_FILE" of="$1" status=progress oflag=sync
exit_status="$?"
END_TIME="$(date +%s)"
ELAPSED_TIME="$(( END_TIME - START_TIME ))"

if [ "$exit_status" -ne 0 ]; then
        echo "[ERROR] Failed to write image after $ELAPSED_TIME seconds."
        exit 1
fi

echo "[SUCCESS] Wrote image in $ELAPSED_TIME seconds."
