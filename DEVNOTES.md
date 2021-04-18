# Development Notes

## Todo List (ordered by priority)

Add an asap Readme.

Build a saplib `neovim` rc.

Write saplib uninstallation script.

Port `fzf-utils.fish` to bash

Add a script creation utility, backed by a textfile modification library.
It creates script snippets with the proper shebang, headers etc.

Migrate to a more sensible build system for both asap and sapling.

Consider writing a pkgbuild for sapling and host it on the AUR.

Rebuild the python library and package it for use with pip:

        - implement a user messages/user input library
        - implement a textfile modification library

Figure out config file management. Add `ansible` integration. Add playbooks.

Make asap `fzf`-based. maybe rewrite asap in fishscript.

Asap LVM-on-LUKS integration.

Write a saplib implementation of what `color` does and make the saplign public
under GPLv3 if possible.

Write more asap packagelists.

Add packages and default configs for `ufw`. Have a look at `fail2ban`.

Add a utility to collect scripts/project meta-information.
It parses script headers for tags like `@dependencies`, `@version` etc and makes
this information accessible.

Add a global/per-user saplib config file and a cli frontend to edit it.
It allows customizing saplib functionality.

...
