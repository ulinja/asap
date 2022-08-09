# ASAP configuration file

The target system built by ASAP is configured using `target.yml`.

## Partitioning

ASAP provides a very simple auto-partitioning mode, which creates `root`, `boot` and `swap` partitions on `/dev/sda` for you using [LVM](https://wiki.archlinux.org/title/LVM).
**WARNING:** Auto-partitioning erases data on the `/dev/sda` drive irrevocably!
You should only use it on systems which only have one drive (HDD) whose data can be discarded, and where a simple partitioning scheme is acceptable.
*NOTE:* You **must** enable the `lvm2` [mkinitcpio hook](#mkinitcpio) if you use auto-partitioning.

If you have a more complex setup, you have to perform the following steps yourself:

1. Creation of partitions and filesystems
2. Mounting the created filesystems:
  - the `root` partition must be mounted at `/mnt`
  - the `boot` partition must be mounted at `/mnt/boot`
3. Creating `/mnt/etc/fstab`

You can automate these steps for your individual setup by modifying [stage2](/profile/airootfs/usr/local/lib/asap/stages/stage2.py).

## Mirrorlist

You can modify which mirrors pacman uses by setting configuration options here.
ASAP uses [reflector](https://wiki.archlinux.org/title/Reflector) to obtain a mirrorlist.
Run `reflector -h` to get a list of valid configuration values.

## Timezone

ASAP sets the timezone using the directories under `/usr/share/zoneinfo`.

## Console

Sets the keymaps (keyboard layout) and/or fonts for the TTY console on the target system.
Available keymaps can be listed with:

```sh
find /usr/share/kbd/keymaps -name '*.map.gz' -printf '%f\n' | awk -F '.' '{print $1}' | sort | less
```

Available fonts can be listed with:

```sh
find /usr/share/kbd/consolefonts -name '*.gz*' -printf '%f\n' | awk -F '.' '{print $1}' | sort | less
```

and previewed on [this helpful website](https://adeverteuil.github.io/linux-console-fonts-screenshots/).

## Hostname

The hostname of the target machine.

## Domain Name

The domain to which the target machine will belong.
You can leave this empty if it does not matter or if you are unsure.

## Username

The name of the non-root user who will be created.

## Mkinitcpio

This setting determines the [mkinitcpio hooks](https://wiki.archlinux.org/title/Mkinitcpio#Common_hooks) used during the target system's boot process.
Which hooks you need depends on your specific setup.

## Locale

The locale settings of the target system. These are optional and default to `en_US.UTF-8` if the `locale` key is omitted.

You can change the system locale by setting the `LANG` variable, to which all other locale values will default unless individually specified.

## Packages

The list of pacman packages which the target system will be bootstrapped with.
