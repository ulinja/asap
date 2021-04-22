# Introduction

Sapling is an extended base install of Arch Linux. It includes a fully automated,
extensible installation suite called [ASAP](/asap/README.md) and runs based on
the [Saplib](/saplib/README.md) multi-language library.

Sapling provides a modern base for any server or desktop linux system, as
'vanilla' Arch Linux does, albeit slightly extended with **system-wide**
integration of certain features, among which are:

- the `fish` shell as the interactive shell
- the `bat` pager utility
- the `exa` file discovery utility
- fast commandline navigation using `fzf`
- a coding-oriented flavor of the `neovim` text editor

This list will surely grow bigger with time, but Sapling will always be a minimal
Linux base system (minimal with regards to hardware from within the last decade).

Using the above utilities is not *required*: you can use the ASAP installer and
not install Saplib / you can install Saplib on any existing Arch linux system
without the use of ASAP.

*NOTE: The fish shell is the default login shell in Sapling, but bash and zsh are
also fully supported, and Saplib provides many common functions/aliases for all
three shells.*

## Installation

This is where Sapling shines and it is the the original reason for Sapling's inception!

Sapling is installed through the ASAP commandline-based installation suite.
ASAP is very modular in nature while still being fully automated.
See [here](/asap/README.md) for a description of what ASAP can do.

## Roadmap

- LVM-on-LUKS Full Disk Encryption Support (almost finished)
- cross-system configuration management
- Ansible Integration
- 'ufw' firewall integration
- Many many useful utilities and integrations for distinguished CLI enjoyers
