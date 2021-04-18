# Introduction

Sapling is my base install of Arch Linux. It includes an extensible installation
suite called 'asap' and runs based on a multi-language library called 'saplib'.

Sapling is a minimal base system, like vanilla Arch Linux, albeit slightly extended
with **system-wide** integration of certain features, among which are:

- the `fish` shell
- the `bat` pager utility
- the `exa` file discovery utility
- fast commandline navigation using 'fzf'

This list will surely grow bigger with time, but Sapling will always be a minimal
Linux base system (minimal with regards to hardware from the last decade).

*NOTE: The fish shell is the default login shell in Sapling, but bash and zsh are
also fully supported, and saplib provides many common functions/aliases for all
three shells.*

## Installation

This is where Sapling shines and it is the the original reason for Sapling's inception!

Sapling is installed through the **asap** commandline installation suite.
By default, asap is a mostly automated Arch Linux installation script.
It is very modular in nature however, and additional installation scripts can easily
be compiled right into the asap installation medium, which is created using the archiso
utility.

Asap aims to be very customizable through its configuration file and a set of prebuilt
packagelists, while still being highly automated.

## Roadmap

- Full Disk Encryption Support (almost finished)
- A saplib neovim preset
- Ansible Integration / cross-system configuration file management
- 'ufw' firewall integration
- Many many useful utilities and integrations for distinguished CLI enjoyers
