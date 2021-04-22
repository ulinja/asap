# Development Notes

## Todo List (ordered by priority)

- [x] Build a `neovim` rc.
- [ ] Write an uninstallation script.
- [ ] Port `fzf-utils.fish` to bash
- [ ] Add a script creation utility, backed by a textfile modification library.
- [ ] creates script snippets with the proper shebang, headers etc.
- [ ] Migrate to a more sensible build system.
- [ ] Write a pkgbuild and host it on the AUR.
- [ ] Rebuild the python library and package it for use with pip:
        - implement a user messages/user input library
        - implement a textfile modification library
- [ ] Figure out config file management. Add `ansible` integration. Add playbooks.
- [ ] Write a saplib implementation of what `color` does
- [ ]. Add a utility to collect scripts/project meta-information.
        - parses script headers for tags like `@dependencies`, `@version` etc and makes this information accessible.
- [ ]. Add a global/per-user saplib config file and a cli frontend to edit it.
        - allows customizing saplib functionality.
