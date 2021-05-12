#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Creates the default non-root user.
# ----------------------------------------------------------------------------- #
# @file    3-03_set-hostname-and-networksettings.sh
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

DEFAULT_USERNAME="saplinguser"

# query for user input until user confirms the chosen hostname
myuser="$DEFAULT_HOSTNAME"
query_successful=false
while [ ! $query_successful = true ]; do
        # prompt user to input
        info_message "Please set a username for the default non-root user on the new system."
        printf "Username: " ; read userinput
        info_message "You have chosen $userinput as the username."
        prompt_yes_or_no "Is that correct?"
        if [ "$?" -eq 0 ]; then
                myuser="$userinput"
                query_successful=true
        fi
done
info_message "Creating user $myuser"
useradd -mU "$myuser"
usermod -aG audio,optical,storage,uucp,video,wheel "$myuser"

info_message "Please set a new password for $myuser now:"
passwd $myuser
if [ "$?" -ne 0 ]; then
        error_message "Failed to set $myuser's password!"
        warning_message "Aborting..."
        exit 1
fi
success_message "$myuser's password was set."

info_message "Installing neovim plugins for $myuser..."
sudo -u $myuser nvim -c ":PlugInstall" -c ":qa"
sudo -u $myuser nvim -c ":CocUpdateSync" -c ":qa"

success_message "User creation complete."
exit 0
