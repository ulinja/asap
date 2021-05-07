# Development Notes for asap

## Todo List (ordered by priority)

- [x] Add a Readme.
- [ ] Host pre-compiled latest ISO
- [ ] Create the default non-root user during installation
- [ ] LVM-on-LUKS integration.
- [ ] clean up asap command syntax
- [ ] Make user interaction `fzf`-based where possible.
- [ ] Add an asap uninstallation script to remove asap-envvars and scripts after installation
- [ ] Migrate to a more sensible build system.
- [ ] Wrap asap_functions.sh in python instead of bash
- [ ] Use archiso-base over archiso-releng as the base profile to make the ISO tiny
- [ ] Write more packagelist presets:
- headless server
- i3wm + polybar + rofi desktop
- KDE plasma desktop

## Implementation Details

### Saplib on the asap archiso
