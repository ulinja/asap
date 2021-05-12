# Wrapper script to load saplib's fish configuration

# Disable the greeting message
function fish_greeting
end

# Enable vi-mode by default
fish_vi_key_bindings

# cargo config directory
set --global --export CARGO_HOME $HOME/.config/cargo
# cargo binary installation target directory
set --global --export CARGO_INSTALL_ROOT $HOME/.local/bin

# Source all of saplib's fish functions
for scriptfile in /usr/local/lib/saplib/fish/src/*.fish
        source $scriptfile
end
