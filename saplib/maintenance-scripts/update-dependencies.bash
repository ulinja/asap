#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Updates the dependencies inside the repo.
# ----------------------------------------------------------------------------- #
# @file    update-dependencies.bash
# @version 1.0
# @author  cybork
# @email   
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
THIS_DIR="$(dirname $(realpath $0))"
DEPENDENCIES_DIR="$THIS_DIR/../build/dependencies"

# make sure user is not root
if [ "$(id -u)" -eq 0 ]; then
        echo "[ERROR] Don't run this script as root."
        exit 1
fi

# update 'pisces'
rm -rf "$DEPENDENCIES_DIR"/pisces/*
GIT_TMP_DIR="/tmp/git-tmp"
git clone 'https://github.com/laughedelic/pisces.git' "$GIT_TMP_DIR"
cp -r "$GIT_TMP_DIR"/* "$DEPENDENCIES_DIR"/pisces/
rm -rf "$GIT_TMP_DIR"
unset -v GIT_TMP_DIR

# update 'color'
rm -rf "$DEPENDENCIES_DIR"/color/*
GIT_TMP_DIR="/tmp/git-tmp"
git clone 'https://github.com/ali5ter/ansi-color.git' "$GIT_TMP_DIR"
cp -r "$GIT_TMP_DIR"/ansi-color/* "$DEPENDENCIES_DIR"/color/
rm -rf "$GIT_TMP_DIR"
unset -v GIT_TMP_DIR

echo ""
echo "Updated the dependencies."
