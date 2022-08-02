# Global custom fish configuration file

# Disable the greeting message
function fish_greeting
end

# Enable vi-mode by default
fish_vi_key_bindings

# Source all custom fish functions
for scriptfile in /usr/local/lib/fish/src/*.fish
        source $scriptfile
end
