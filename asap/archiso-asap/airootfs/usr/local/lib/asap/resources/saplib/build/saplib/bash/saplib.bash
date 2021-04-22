#!/usr/bin/env bash
# Wrapper script used to source all of saplib's bash functions.

# Source every bash script except the aliases and prompt
for scriptfile in /usr/local/lib/saplib/bash/src/*.bash ; do
        scriptname="$(basename $scriptfile)"
        if [ "$scriptname" != 'aliases.bash' -a "$scriptname" != 'prompt.bash' ]; then
                source "$scriptfile"
        fi
done
