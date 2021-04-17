#!/usr/bin/env bash

# Generates a WPA2 WiFi pre-shared key on the archiso.
# See 'https://wiki.archlinux.org/index.php/Iwd#Network_configuration' for info
# DEPENDENCIES: wpa_supplicant

# this is used to enable relative path usage from within this script's parent dir
THIS_SCRIPT_DIR="$(dirname $(realpath $0))"
# source build config
source "$THIS_SCRIPT_DIR"/build-config
if [ "$?" -ne 0 ]; then
        echo "[ERROR] Failed to source build config."
        exit 1
fi

prompt_yes_or_no "Do you want to embed the credentials to autoconnect to a WPA2 WLAN network on the ISO?"
if [ "$?" -ne 0 ]; then
        info_message "Skipping iwd psk generation."
        exit 0
fi

read -p "Enter your WLAN's SSID: " SSID_RAW
read -s -p "Enter $SSID_RAW's password (will not be echoed): " PASSWORD_RAW
echo ""

# XXX not needed unless SSID contains characters other than [a-zA-Z_- ]
#SSID_ENCODED="$(echo -n $SSID_RAW | od -A n -t x1 | sed 's/ //g')"

# encode the password
PASSWORD_ENCODED="$(wpa_passphrase $SSID_RAW $PASSWORD_RAW | grep '[[:space:]]psk' | sed 's/\spsk=//')"

# create the iwd psk
TARGET_FILE="$ARCHISO_PROFILE_DIR/airootfs/var/lib/iwd/$SSID_RAW.psk"
echo "[Security]" > "$TARGET_FILE"
echo "PreSharedKey=$PASSWORD_ENCODED" >> "$TARGET_FILE"

success_message "The WPA2 pre-shared key was created at '$TARGET_FILE'."
exit 0
