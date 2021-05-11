# SAPLIB

*Version 0.4*

Saplib is a custom library for multiple scripting languages, with system administration
in mind.
Saplib provides interactive shell aliases for `bash`, `zsh` and `fish`.
Library functions for use in scripting are also provided for all the above.

Saplib sets global default configurations for:

* `bash`
* `zsh`
* `fish`
* `neovim`

:heavy_exclamation_mark: *Saplib is my personal library and it sets **global**
default configurations for the above-mentioned applications.
Although it should play nice with existing systems, it is really more intended
for building your system around it and with its defaults in mind.
Spin up a VM (with efi enabled) and boot from the latest [ASAP](/asap/README.md)
live medium (which makes the installation a breeze :rocket:) to try it out.
At the moment, ASAP installs Saplib to the created system automatically.*

## Installation

If you used [ASAP](/asap), Saplib is already installed and no further action is necessary.

If not, simply run the saplib installation script with root privileges:

```bash
sudo /bin/bash saplib/install.bash
```

You will have to log out and back in (or reboot) for the changes to take effect,
because Saplib modifies your global environment.

### Dependencies

The following Arch Linux packages are required to use all of saplib's features:

* `bat`
* `exa`
* `fzf`
* `git`
* `rsync`
* `trash-cli`
* `perl-rename`

If you used ASAP, the above-mentioned packages will have been installed already.

## Uninstallation

:heavy_exclamation_mark: *The uninstallation script is not implemented
yet...*

Simply run the uninstallation script with root privileges:

```bash
sudo /bin/bash saplib/install-scripts/uninstall.bash
```

You will have to log out and back in (or reboot) for the changes to take effect.

## Additional Information / Hacking

### BASH

Saplib's bash scripts are stored in `/usr/local/lib/saplib/bash/src`.
`aliases.sh` and `prompt.sh` are sourced directly in `/etc/bash.bashrc`, as they
are only needed when bash is running interactively.

All other saplib bash scripts define functions for importing and using in bash
scripts.
A wrapper script is used to source them all at once. A global environment
variable pointing to the wrapper script is set in `/etc/environment`, called
`$SAPLIB_BASH`. This allows calling `source $SAPLIB_BASH` in any shell scripts
in which you want to make use of saplib's bash functions.

:heavy_exclamation_mark: Do not remove the `@SAPLIB*` tags from the above-mentioned files,
as doing so could fill those files more and more each time you update saplib and
break saplib's uninstallation scripts. *(Why would you ever uninstall it though? :smirk:)*

### FISH

Saplib's fish scripts are stored under `/usr/local/lib/saplib/fish/src` and
globally sourced by a symlink inside `/etc/fish/conf.d` pointing at the wrapper
script `/usr/local/lib/saplib/fish/saplib.fish`, which loads all of saplib's fish
functions. See the [fish documentation](https://fishshell.com/docs/current/index.html#initialization-files)
for more information.

Saplib also comes with some 3rd Party fish plugins, licensed under LGPLv3.
(Currently just [this one](https://github.com/laughedelic/pisces))

### PYTHON

Saplib python is not yet implemented.
Installation of the saplib python library will be handled via simple pip installation.

### Dependencies

The `color` script goes into `/usr/local/bin` and its man-page `color.1` goes
into `/usr/share/man/man1`.
