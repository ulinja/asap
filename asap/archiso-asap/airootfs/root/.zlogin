# fix for screen readers
if grep -Fq 'accessibility=' /proc/cmdline &> /dev/null; then
    setopt SINGLE_LINE_ZLE
fi

~/.automated_script.sh

# Source saplib aliases
source /usr/local/lib/saplib/bash/src/aliases.bash

# Source saplib prompt
source /usr/local/lib/saplib/bash/src/prompt.bash
