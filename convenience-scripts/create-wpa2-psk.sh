#!/usr/bin/env bash

# Generates a WPA2 WiFi pre-shared key used for by linux live-medium to
# autoconnect to a WiFi network.
# The generated key is placed into asap/credentials/wpa-preshared-key/ .
# If you run this script prior to building the ASAP ISO, the key will be auto-
# matically embedded on the built image, and any WiFi-capable device booting
# the ASAP ISO will connect to your WiFi network automatically.
#
# See 'https://wiki.archlinux.org/index.php/Iwd#Network_configuration' for info
# DEPENDENCIES: wpa_supplicant
THIS_DIR=$(dirname $(realpath $0))

read -p "Enter your WLAN's SSID: " SSID_RAW
read -s -p "Enter $SSID_RAW's password (will not be echoed): " PASSWORD_RAW
echo ""

TARGET_FILE="$THIS_DIR/../credentials/wpa-preshared-key/$SSID_RAW.psk"

# XXX use this as the target file name instead if the SSID contains characters other than [a-zA-Z_- ]
#SSID_ENCODED="$(echo -n $SSID_RAW | od -A n -t x1 | sed 's/ //g')"
#TARGET_FILE="$THIS_DIR/../credentials/wpa-preshared-key/$SSID_ENCODED.psk"

# encode the password
PASSWORD_ENCODED="$(wpa_passphrase $SSID_RAW $PASSWORD_RAW | grep '[[:space:]]psk' | sed 's/\spsk=//')"

# create the iwd psk
echo "[Security]" > "$TARGET_FILE"
echo "PreSharedKey=$PASSWORD_ENCODED" >> "$TARGET_FILE"

echo "[SUCCESS] The WPA2 pre-shared key was created at '$TARGET_FILE'."
exit 0
