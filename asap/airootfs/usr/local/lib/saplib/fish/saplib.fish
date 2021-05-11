# Wrapper script to load saplib's fish configuration

# Disable the greeting message
function fish_greeting
end

# Enable vi-mode by default
fish_vi_key_bindings

# set the cargo package manager installation directory
set --global --export CARGO_HOME /usr/local/lib/cargo
# add the cargo binaries directory to PATH
fish_add_path --global /usr/local/lib/cargo/bin

# Source all of saplib's fish functions
for scriptfile in /usr/local/lib/saplib/fish/src/*.fish
        source $scriptfile
end
