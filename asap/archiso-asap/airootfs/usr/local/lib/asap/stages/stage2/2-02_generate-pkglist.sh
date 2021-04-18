#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# TODO Fix this description
# Generates a packagelist from supplied packagelists.
# See ../resources/packagelists/ for some lists.
# Commented-out (#) packages will be ignored, so edit the lists as necessary
# before running this script.
# The resulting packagelist can be used to pacstrap the system.
# It is output to the current directory.
# ----------------------------------------------------------------------------- #
# @file    2-02_generate-pkglist.sh
# @version 1.0
# @author  cybork
# @email   
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

##### source the necessary libraries
libraries=(
        "$SAPLIB_BASH"
        "$ASAP_CONFIG"
        "$ASAP_FUNCTIONS"
)
for lib in "${libraries[@]}"; do
        source $lib
        if [ "$?" -ne 0 ]; then
                echo "[EXCEPTION] Failed to source $lib."
                exit 1
        fi
done

################################# BEGIN SCRIPT ##################################
# TODO make packagelist selection interactive

OUTFILE="$ASAP_WORKING_DIR/asap-packagelist.pac"
PACKAGELISTS_DIR="$ASAP_RESOURCES_DIR/packagelists"

# add packagelists from /usr/local/lib/asap/resources/packagelists/ here
PACKAGELISTS_USED=(
        "$PACKAGELISTS_DIR/base.pac"
        "$PACKAGELISTS_DIR/amd-cpu.pac"
        "$PACKAGELISTS_DIR/wifi.pac"
        )

# make sure packagelist files exist/are readable
for pkglist in "${PACKAGELISTS_USED[@]}"
do
        if [ -r "$pkglist" ]
        then
                info_message "Using packagelist $(basename $pkglist)"
        else
                error_message "$pkglist: file could not be accessed!"
                warning_message 'Aborting...'
                exit 1
        fi
done

# generate a packagelist and remove all empty and commented lines
rm -f "$OUTFILE"
for pkglist in "${PACKAGELISTS_USED[@]}"
do
        grep -v '^$' "$pkglist" | grep -v '\#' | tr '\n' ' ' >> "$OUTFILE"
        debug_message "Added packages from $pkglist"
done

success_message "Generated packagelist $OUTFILE"
exit 0
