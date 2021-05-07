# :hourglass:    ASAP    :hourglass:

*Version 0.8.0-alpha*

## About

ASAP is an automated installation suite for Arch Linux, simplifying a complete
installation into typing a few intuitive commands and watching the process on your
terminal:

![ASAP Demo](/asap/img/stage3.gif)

### Getting started

ASAP runs in distinct stages:

Stage Number | Stage Overview
------------ | --------------
Stage 0 | Initialize installation resources
Stage 1 | Drive partitioning, formatting & mounting
Stage 2 | Bootstrapping (pre-chroot)
Stage 3 | System setup (post-chroot)

![ASAP Demo](/asap/img/stage0.gif)

Begin a stage by running the following, where `X` is the stage number:

```bash
asap_stage-X
```

You can run your own commands in between stages. With the exception of stage 1,
no manual intervention is required for a standard installation.

## How it works

To check which installation scripts have run successfully, run:

```bash
asap_check-progress
```

This will display the contents of the asap checkpoint-file. Scripts listed in the
checkpoint-file will not be run again. This is useful if something went wrong: you
can fix the issue and just rerun the stage entirely using `asap_stage-X`.

To manually add a script to the checkpoint-file, use:

```bash
asap_set-checkpoint 'myCheckpoint'
```

where `myCheckpoint` is a stage-checkpoint in the form `stageX` or the filename
of a script.

### Packages

Asap comes with a few package-lists by default. They define which packages are installed
on your base system and can be freely modified. By default, they are limited to
a minimal list of linux utilities, including the [Saplib](/saplib/README.md) library.

## Customization

ASAP is customizable and extensible: you can **bake your own scripts right into the
installation medium**, and they will be executed and logged automatically by ASAP.
Building your own installation medium is very easy with the provided ASAP
archiso-profile and ISO-generation scripts.
Building an installation image is limited to Arch-based systems though, and requires
the [archiso](https://wiki.archlinux.org/index.php/Archiso) package to be installed.

### Roadmap

- LVM-on-LUKS Full Disk Encryption Support (almost finished)
- Option to display previews of what each script in a stage does prior to running it
