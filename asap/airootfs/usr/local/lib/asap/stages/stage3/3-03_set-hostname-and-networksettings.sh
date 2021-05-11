#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Sets the hostname and network configuration on the new system.
# The network configuration and the associated files created during the process
# are tied together, hence this script aims to handle both.
# TODO Implement static configuration. Network config is currently assumed to be
# DHCP.
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

DEFAULT_HOSTNAME="saplingmachine"

# query for user input until user confirms the chosen hostname
myhost="$DEFAULT_HOSTNAME"
query_successful=false
while [ ! $query_successful = true ]; do
        # prompt user to input
        info_message "Please set a hostname for your new system."
        printf "Hostname: " ; read userinput
        info_message "You have chosen $userinput as the hostname."
        prompt_yes_or_no "Is that correct?"
        if [ "$?" -eq 0 ]; then
                myhost="$userinput"
                query_successful=true
        fi
done
info_message "Using hostname $myhost"

# create hostname file
echo "$myhost" >> /etc/hostname

# create /etc/hosts
info_message "Creating '/etc/hosts' file..."
echo "127.0.0.1        localhost" >> /etc/hosts
echo "::1              localhost" >> /etc/hosts
echo "127.0.1.1        $myhost.localdomain $myhost" >> /etc/hosts

# enable DHCP
info_message "Enabling dhcpcd..."
systemctl enable dhcpcd
if [ "$?" -ne 0 ]; then
        error_message "Failed to enable dhcpcd.service"
        warning_message "Aborting..."
        exit 1
fi

success_message "Hostname configuration complete."
exit 0
