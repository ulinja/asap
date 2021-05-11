# Sapling

Sapling is an extended Arch Linux base installation.
It runs using its own multi-language library called [Saplib](#saplib), which
provides useful commandline functions and scripting libraries.

## About

Much like "vanilla" Arch Linux, it is by default a *base system*, customizable
to suit many different use cases: be it a headless server, low-power-footprint
laptop or a high end workstation.

Sapling is designed with commandline-usage in mind, albeit extending the traditional
Linux experience. With carefully customized versions of tried-and-true utilities
or modern reimplementations of them, it provides **system-wide** integration of,
among others:

- the `fish` shell (as the default interactive shell)
- the `bat` pager utility
- the `exa` file discovery utility
- fast commandline navigation using `fzf`
- a custom, full IDE-like flavor of the `neovim` text editor

> :grey_exclamation: *`fish` is the default login shell in Sapling, but `bash` and `zsh`
> are also fully supported and Saplib implements the same useful functions/aliases
> for all three shells.*

## Installation

> :heavy_exclamation_mark: *Sapling sets default configurations for many **core system settings**,
> the root user and the above-mentioned applications on a system-wide scale.
> Although it should work on existing systems, it is intended for building your
> system around it. Installation should occur after bootstrapping your arch linux
> installation, and before creating any non-root users.*

Simply run the Makefile as the root user:

```bash
    git clone https://github.com/ulinja/sapling.git
    cd sapling
    make install
```

You must reboot the system for all changes to take effect (as Sapling sets some
defaults in different global environment files).

## Saplib

Saplib is a custom library for multiple scripting languages, with system
administration and shell scripting in mind.
It provides interactive shell aliases for `bash`, `zsh` and `fish`.
Library functions for use in scripting are also provided for all the above.

Sapling sets global default configurations for:

* the root shell, new user's shells
* new user's home directory structure (`/etc/skel`). Customizable before installation.
* default applications and shell behaviour
* `bash`
* `zsh`
* `fish`
* `neovim`

### Dependencies

All dependencies which get installed alongside Saplib are listed at the top
of the [Makefile](Makefile).
Note that `texlive-most` is quite heavy in terms of disk space (2 GB), and
completely optional: feel free to remove it from `NVIM_PACMAN_DEPS` in the
Makefile prior to installation.

## Updating

Clone/Pull the latest Sapling master and run `make update`.

## Uninstallation

:heavy_exclamation_mark: *An uninstallation script is not implemented and likely never will be.*

### Additional Information / Hacking

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

### FISH

Saplib's fish scripts are stored under `/usr/local/lib/saplib/fish/src` and
globally sourced by a symlink inside `/etc/fish/conf.d` pointing at the wrapper
script `/usr/local/lib/saplib/fish/saplib.fish`, which loads all of saplib's fish
functions. See the [fish documentation](https://fishshell.com/docs/current/index.html#initialization-files) for more information.

Saplib also comes with some 3rd Party fish plugins, licensed under LGPLv3.
(Currently just [this one](https://github.com/laughedelic/pisces))

### PYTHON

Saplib python is not yet implemented.
Installation of the saplib python library will be handled via simple pip installation.

### Roadmap

- A python library
- Desktop presets through Ansible playbooks
