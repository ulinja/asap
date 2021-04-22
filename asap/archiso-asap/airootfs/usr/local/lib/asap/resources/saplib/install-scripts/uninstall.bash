#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Uninstalls saplib from the system.
# ----------------------------------------------------------------------------- #
# @file    install.bash
# @version 1.0
# @author  cybork
# @email   
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
THIS_DIR="$(dirname $(realpath $0))"
BUILD_DIR="$THIS_DIR/../build"

# check if user is root
if [ "$(id -u)" -ne 0 ]; then
        echo "[ERROR] You must have root privileges for the installation."
        exit 1
fi

# TODO implement
echo "[EXCEPTION] Not yet implemented."
exit 1
