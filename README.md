# ASAP

ASAP is a tool for building automated Arch Linux installations.

It consists of an [archiso](https://wiki.archlinux.org/title/Archiso) profile which is used to build a custom ISO, and the [asap application]() which is used to run the installation process.

Both the ISO and the installation process are fully customizable. You can add arbitrary files and packages to the ISO. ASAP is written in python and designed to be very easily extensible.

# Requirements

**Build machine:**

- Arch Linux x86-64
- [archiso](https://archlinux.org/packages/extra/any/archiso/)

**Target machine:**

- UEFI firmware
- x86-64 architecture

# Building an ISO

To get started, clone the repo and edit the [target system configuration file](/profile/airootfs/etc/asap/) to your liking:

```bash
git clone github.com/ulinja/asap.git
cd asap
$EDITOR profile/airootfs/etc/asap/target.yml
```

Optionally, you can add your SSH public key to the live image and target system by placing them here prior to building the image:

```bash
cp ~/.ssh/id_rsa.pub credentials/ssh-public-key/
```

this will let you ssh into both the live USB and the final system.

If your target system uses a wireless network interface, you can optionally prep the ISO by running

```bash
./convenience-scripts/create-wpa2-psk.sh
```

to add your wifi-network's credentials to the live USB and have it connect automatically on boot.

Now you can build your personal Arch installation ISO by running

```bash
sudo make build
```

# Running the installation

Once you have [built your ISO](#building-an-iso), you can boot it from USB or in a VM, just make sure you boot in UEFI-mode.

Once booted, you can run

```bash
asap info config
```

to double-check your configuration. If you want to edit anything, you can modify `/etc/asap/target.yml` on the live system to make changes.

Start the installation by running

```bash
asap run
```

and keep an eye on the output, as some steps require some manual interaction.

If any step fails during the installation, the installer stops running and tells you what went wrong.
To get an overview of where you are in the installation, you can always run

```bash
asap info checkpoints
```

to see which installation steps have been successful/unsuccessful/unattempted.
Once you have fixed the error, you can simply invoke `asap run` again to resume where you left off.

# Customizing ASAP

ASAP was designed to be fully customizable.

*TODO: write howto*
