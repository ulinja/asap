# :seedling:    SAPLING    :seedling:

## About

Sapling is an extended Arch Linux base installation.

It runs using its own multi-language library called [Saplib](/saplib/)
and is installed through a fully automated, extensible installation suite called
[ASAP](/asap/).

Much like "vanilla" Arch Linux, it is by default a *base system*, customizable
to suit many different use cases: be it a headless server, low-power-footprint
laptop or a high end workstation. In contrast to it, the installation process is
almost fully automated.

Sapling is designed with commandline-usage in mind, albeit extending the traditional
Linux experience. With carefully customized versions of tried-and-true utilities
or modern reimplementations of them, it provides **system-wide** integration of,
among others:

- the `fish` shell (as the default interactive shell)
- the `bat` pager utility
- the `exa` file discovery utility
- fast commandline navigation using `fzf`
- a coding-oriented flavor of the `neovim` text editor

> :grey_exclamation: *`fish` is the default login shell in Sapling, but `bash` and `zsh`
> are also fully supported and Saplib implements the same useful functions/aliases
> for all three shells.*

## :rocket: Installation

Sapling is installed through the [ASAP](/asap/) commandline-based installation suite.

Trying out Sapling is pretty easy: just spin up a VM using the [latest ASAP installation medium](https://github.com/404)
and give the installation a shot.

### Roadmap

- Cross-system configuration management
- Desktop presets through Ansible playbooks
