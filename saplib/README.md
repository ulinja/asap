# SAPLIB

Version 0.3

Saplib is a library for multiple scripting languages, globally accessible by
every user on a system.

Saplib currently provides interactive shell aliases for bash, and shell
functions for fish. Additionally, for python and bash, library functions are
provided for use in scripting.

## Installation

### BASH

The bash scripts are stored in '/usr/local/lib/saplib/bash/src'.
'aliases.sh' is sourced directly in '/etc/bash.bashrc', as they are only needed
when bash is running interactively.

All other saplib bash scripts only define functions. While it is possible to make
them globally available by pointing at them with a globally set '$BASH_ENV'
variable, this carries unpleasant security and performance implications with it.

Thus, a wrapper script is used to source them all at once. A global environment
variable pointing to the wrapper script is set in '/etc/environment', called
'$SAPLIB_BASH'. This allows calling 'source $SAPLIB_BASH' in any shell scripts
which need to make use of saplib's bash functions.

### FISH

Fish scripts are somewhat easier to install. They are stored in
'/usr/local/lib/saplib/fish/src' and globally sourced by a symlink inside
'/etc/fish/conf.d' pointing at the wrapper script
'/usr/local/lib/saplib/fish/saplib.fish', which loads all of saplib's fish
functions.

### PYTHON

Saplib python is not yet implemented.
Installation of the saplib python library is handled by pip.

## Uninstallation

Uninstallation of saplib from a system is not supported! Saplib goes hand-in-hand
with a complete Sapling installation, and will leave many scripts on the system
unusable.

Uninstallation must be handled manually by editing the above mentioned config
files, as well as through pip.

## Dependencies

The 'color' script goes into '/usr/local/bin' and its man-page 'color.1' goes
into '/usr/share/man/man1'.

The following Arch Linux packages are required to use all of saplib's features:

- bat
- exa
- git
- rsync
- trash-cli
- perl-rename

The following AUR packages are required to use all of saplib's features:

- fisher
