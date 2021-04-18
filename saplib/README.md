# SAPLIB

Version 0.4

Saplib is a library for multiple scripting languages, globally accessible by
every user on a system.

Saplib currently provides interactive shell aliases for bash (and zsh), and shell
functions for fish.

Additionally, for all the above, library functions are provided for use in scripting.

## Installation

### BASH

The bash scripts are stored in '/usr/local/lib/saplib/bash/src'.
'aliases.sh' and 'prompt.sh' are sourced directly in '/etc/bash.bashrc', as they
are only needed when bash is running interactively.

All other saplib bash scripts define functions for importing and using in bash
scripts. While it is possible to make
them globally available by pointing at them with a globally set '$BASH_ENV'
variable, this carries unpleasant security and performance implications with it.

Thus, a wrapper script is used to source them all at once. A global environment
variable pointing to the wrapper script is set in '/etc/environment', called
'$SAPLIB_BASH'. This allows calling 'source $SAPLIB_BASH' in any shell scripts
which need to make use of saplib's bash functions.

While installed, do not remove the '@SAPLIB*' tags from the above-mentioned files,
as doing so could fill those file more and more each time you update saplib.

### FISH

Fish scripts are somewhat easier to install. They are stored in
'/usr/local/lib/saplib/fish/src' and globally sourced by a symlink inside
'/etc/fish/conf.d' pointing at the wrapper script
'/usr/local/lib/saplib/fish/saplib.fish', which loads all of saplib's fish
functions.

Saplib also comes with some 3rd Party fish plugins, licensed under LGPLv3.
(Currently just [this one](https://github.com/laughedelic/pisces))

### PYTHON

Saplib python is not yet implemented.
Installation of the saplib python library will handled by pip.

## Uninstallation

Uninstallation of saplib from your system is not yet supported.
An uninstallation script is in the making.

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

- yay
