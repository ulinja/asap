# ASAP

*Version A-2.2.1 (Alpha)*

## Introduction

**ASAP** is short for "Archlinux Sapling". It's not just an acronym though, as
the name suggests it will provide you with Arch Linux Sapling *as soon as possible*!

ASAP is a fully automated installation suite for Arch Linux, simplyfying an Arch
install to typing a few intuitive commands and watching the process on StdOut:

*TODO: Add a nice gif of the installation process*

## Customization

### Control

ASAP runs in multiple distinct stages. You are always able to run your own
commands in between stages and still have full control of the process.
You can modify the bite-sized installation scripts at any time.
ASAP is built upon error-prevention and preventing duplicate execution: If
something fails in a script, the installation is safely interrupted. You can fix
the error and just rerun the entire stage: the checkpointing system will prevent
any script which already ran successfully from being rerun.

ASAP is customizable and extensible: you can **bake your own scripts right into the
installation medium**, and they will be executed and logged automatically by ASAP.
Building your own installation medium is very easy with the provided ASAP
archiso-profile and ISO-generation scripts.
Building an installation image is limited to Arch-based systems though, and requires
the `[archiso](https://wiki.archlinux.org/index.php/Archiso)` package to be installed.

### Packages

Asap comes with a few package-lists by default. They define which packages are installed
on your base system and can be freely modified. By default, they are limited to
a minimal list of linux utilities, including the `[Saplib](/saplib/README.md)`
library.
