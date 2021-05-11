#!/usr/bin/env bash
# ----------------------------------------------------------------------------- #
# Modifies /etc/locale.gen, generates and imports the custom locale.conf from
# the asap library.
# ----------------------------------------------------------------------------- #
# @file    3-02_setlocale.sh
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

# TODO automate this declaration
LOCALES_USED=(
        'de_DE.UTF-8'
        'en_DK.UTF-8'
        'en_GB.UTF-8'
        'en_US.UTF-8'
        )

PATH_TO_LOCALEGEN='/etc/locale.gen'
PATH_TO_LOCALEDST='/etc/locale.conf'
PATH_TO_LOCALESRC="$ASAP_RESOURCES_DIR/locale.conf"

# uncomment locales from /etc/locale.gen
for locale in "${LOCALES_USED[@]}"
do
        # escape literal periods in the locale string to allow correct sed processing
        locale_sed_string="$(echo $locale | sed 's/\./\\./g')"
        # uncomment locale string in /etc/locale.gen and check if successful
        sed -i "s/#\($locale_sed_string.*\)/\1/" "$PATH_TO_LOCALEGEN"
        if [ "$?" -ne 0 ]; then
                error_message "Failed to uncomment $locale in $PATH_TO_LOCALEGEN"
                warning_message 'Aborting!'
                exit 1
        else
                success_message "Uncommented $locale in $PATH_TO_LOCALEGEN"
        fi
done

# generate locales
locale-gen
if [ "$?" -ne 0 ]
then
        error_message 'Failed to generate locales!'
        warning_message 'Aborting!'
        exit 1
fi
success_message "Generated locales."

# set custom locale configuration: remove commented and empty lines
grep -v '^#.*$' "$PATH_TO_LOCALESRC" | grep -v '^$' > "$PATH_TO_LOCALEDST"
if [ "$?" -ne 0 ]
then
        error_message 'Failed to copy custom locale configuration'
        warning_message 'Aborting!'
        exit 1
fi

success_message 'Set the custom locale configuration.'
info_message 'The locale will update on the next boot.'
exit 0
