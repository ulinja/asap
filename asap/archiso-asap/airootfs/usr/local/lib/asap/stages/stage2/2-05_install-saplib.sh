#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Installs the saplib library to the new system.
# ----------------------------------------------------------------------------- #
# @file    2-05_install-saplib.sh
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

info_message "Installing saplib..."

# install color executable
SRC_FILE="/usr/local/bin/color"
DST_FILE="/mnt$SRC_FILE"
debug_message "Creating '$(dirname $DST_FILE)'"
mkdir -p "$(dirname $DST_FILE)"
if [ "$?" -ne 0 ]; then
        exception_message "Failed to create '$(dirname $DST_FILE)'"
        exit 1
fi
cp "$SRC_FILE" "$DST_FILE"
if [ "$?" -ne 0 ]; then
        exception_message "Failed to copy  '$SRC_FILE' to '$DST_FILE'"
        exit 1
fi
chmod 751 "$DST_FILE"

# install color man page
SRC_FILE="/usr/share/man/man1/color.1"
DST_FILE="/mnt$SRC_FILE"
debug_message "Creating '$(dirname $DST_FILE)'"
mkdir -p "$(dirname $DST_FILE)"
if [ "$?" -ne 0 ]; then
        exception_message "Failed to create '$(dirname $DST_FILE)'"
        exit 1
fi
cp "$SRC_FILE" "$DST_FILE"
if [ "$?" -ne 0 ]; then
        exception_message "Failed to copy  '$SRC_FILE' to '$DST_FILE'"
        exit 1
fi
chmod 644 "$DST_FILE"

# copy the saplib folder
SRC_DIR='/usr/local/lib/saplib'
DST_DIR='/mnt/usr/local/lib'
debug_message "Creating '$DST_DIR'"
mkdir -p "$DST_DIR"
if [ "$?" -ne 0 ]; then
        exception_message "Failed to create '$DST_DIR'"
        exit 1
fi
debug_message "Copying '$SRC_DIR' to '$DST_DIR'"
cp -r "$SRC_DIR" "$DST_DIR"/
if [ "$?" -ne 0 ]; then
        exception_message "Failed to copy  '$SRC_DIR' to '$DST_DIR'"
        exit 1
fi

# create fish config symlink
ln -s /usr/local/lib/saplib/fish/saplib.fish /mnt/etc/fish/conf.d/
# copy fish global config
mkdir -p /mnt/etc/fish
cp -p /etc/fish/config.fish /mnt/etc/fish/

# install /etc/environment
SRC_FILE="/etc/environment"
DST_FILE="/mnt$SRC_FILE"
debug_message "Creating '$(dirname $DST_FILE)'"
mkdir -p "$(dirname $DST_FILE)"
if [ "$?" -ne 0 ]; then
        exception_message "Failed to create '$(dirname $DST_FILE)'"
        exit 1
fi
cp "$SRC_FILE" "$DST_FILE"
if [ "$?" -ne 0 ]; then
        exception_message "Failed to copy  '$SRC_FILE' to '$DST_FILE'"
        exit 1
fi
chmod 644 "$DST_FILE"

# install global bashrc
DST_FILE="/etc/bash.bashrc"
echo "" >> "$DST_FILE"
cat "$ASAP_RESOURCES_DIR"/bash.bashrc.append >> "$DST_FILE"

success_message "Finished installing saplib."
exit 0
