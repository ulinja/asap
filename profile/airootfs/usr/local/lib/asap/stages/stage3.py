from os import getenv
from pathlib import Path
from shutil import copy, chown
from subprocess import PIPE, STDOUT, DEVNULL, run
from tempfile import TemporaryDirectory
import logging
import sys

from core.config import load_config, InvalidConfigFileError
from core.staging import Stage, Step
from core.utils import prompt_yes_or_no


def generate_mirrorlist():
    """Creates the pacman mirrorlist using reflector."""

    CONFIG = load_config()

    # validate CONFIG contents
    if "mirrorlist" in CONFIG:
        conf_ml = CONFIG["mirrorlist"]
        for key in conf_ml:
            if key not in ["protocols", "countries"]:
                raise InvalidConfigFileError(
                    f"Invalid key in mirrorlist configuration: '{key}'."
                )
        if "protocols" in conf_ml:
            if not isinstance(conf_ml["protocols"], list):
                raise InvalidConfigFileError(
                    "Expected a list at 'mirrorlist -> protocols -> LIST'."
                )
            if not len(conf_ml["protocols"]) > 0:
                raise InvalidConfigFileError(
                    "List of protocols cannot be empty if it is present."
                )
            for protocol in conf_ml["protocols"]:
                if not protocol in ["ftp", "http", "https"]:
                    raise InvalidConfigFileError(
                        f"Unexpected mirrorlist protocol: '{protocol}'."
                    )
        if "countries" in conf_ml:
            if not isinstance(conf_ml["countries"], list):
                raise InvalidConfigFileError(
                    "Expected a list at 'mirrorlist -> countries -> LIST'."
                )
            if not len(conf_ml["countries"]) > 0:
                raise InvalidConfigFileError(
                    "List of countries cannot be empty if it is present."
                )
            for country in conf_ml["countries"]:
                if not isinstance(country, str):
                    raise InvalidConfigFileError(
                        f"Mirrorlist country list must contain strings only. "
                        f"Unexpeted type for '{country}': {type(country)}."
                    )
            # XXX actual value of country is not checked

    # build the reflector command
    command = [
        "reflector",
        "--save", "/etc/pacman.d/mirrorlist",
        "--sort", "rate",
    ]
    # add protocols
    if "protocols" in CONFIG["mirrorlist"]:
        command.append("--protocol")
        command.append(",".join(CONFIG["mirrorlist"]["protocols"]))
    # add protocols
    if "countries" in CONFIG["mirrorlist"]:
        command.append("--country")
        command.append(",".join(CONFIG["mirrorlist"]["countries"]))

    logging.info("Generating mirrorlist (this might take a while)...")

    # call reflector
    run(
        command,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=True,
    )

    logging.info("Mirrorlist was generated.")

    # prompt whether user wants to edit the created mirrorlist
    if prompt_yes_or_no(
        "Do you want to edit the created mirrorlist?",
        ask_until_valid=True
    ):
        run([getenv("EDITOR", "vi"), "/etc/pacman.d/mirrorlist"], check=True)


def init_pacman_keyring_iso():
    """Initializes the pacman keyring in the installation medium."""

    logging.info("Initializing pacman keyring (this might take a while)...")

    run(
        ["pacman-key", "--init"],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )
    run(
        ["pacman-key", "--populate", "archlinux"],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )

    logging.info("Pacman keyring was initialized.")



def pacstrap():
    """Runs pacstrap using the packages listed in the config."""

    CONFIG = load_config()

    if "packages" not in CONFIG:
        raise InvalidConfigFileError(
            "No 'packages' key in the config file."
        )
    package_list = CONFIG["packages"]
    if not isinstance(package_list, list):
        raise InvalidConfigFileError(
            "Config key 'packages' must be a list."
        )

    logging.info("Installing packages...")

    # run pacstrap
    run(
        ["pacstrap", "/mnt"] + package_list,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=True,
    )

    logging.info("Packages were installed.")


def set_timezone():
    """Sets the timezone for the new system."""

    CONFIG = load_config()
    if "timezone" not in CONFIG:
        raise InvalidConfigFileError(
            "Key 'timezone' is missing from config file."
        )
    timezone = CONFIG["timezone"]
    if not isinstance(timezone, str):
        raise InvalidConfigFileError(
            "Config key 'timezone' must have a string value."
        )
    # check if provided timezone is valid
    path_to_zoneinfo_file = Path("/mnt/usr/share/zoneinfo") / Path(timezone)
    if not path_to_zoneinfo_file.is_file():
        raise InvalidConfigFileError(
            f"Invalid timezone in config: '{timezone}'."
        )

    # create the tz symlink in the target system
    logging.info("Setting the timezone...")
    run(
        [
            "ln", "-sf",
            str(path_to_zoneinfo_file)[4:],
            "/mnt/etc/localtime",
        ],
        stdout=DEVNULL,
        stdin=DEVNULL,
        check=True,
    )
    logging.info("The timezone was set.")


def sync_hardware_clock():
    """Generates /etc/adjtime on the target system."""

    logging.info("Synchronizing the hardware clock...")
    run(
        [
            "arch-chroot", "/mnt",
            "hwclock", "--systohc",
        ],
        stdout=DEVNULL, stderr=DEVNULL,
        check=True,
    )
    logging.info("The hardware clock was synchronized.")


def _modify_locale_gen_file(locale_dict):
    """Modifies /mnt/etc/locale.gen to contain the needed locales."""

    # get the set of locales to uncomment
    locales = set(locale_dict.values())

    # copy /mnt/etc/locale.gen to a temporary file
    with TemporaryDirectory() as tmp_dir:
        new_file_lines = [
            "# Generated by asap", "\n", "\n",
            "en_US.UTF-8 UTF-8", "\n",
        ]
        # copy and uncomment all lines containing a needed locale
        with open("/mnt/etc/locale.gen", 'r') as orig_file:
            for line in orig_file.readlines():
                for locale in locales:
                    if locale.lower() in line.lower():
                        if line.startswith("#"):
                            new_file_lines.append(f"{line[1:]}")
                        else:
                            new_file_lines.append(f"{line}")
                        if not line.endswith("\n"):
                            new_file_lines.append("\n")

        # write lines into the new file
        path_to_new_file = Path(tmp_dir) / Path("locale.gen")
        with open(path_to_new_file, "w") as new_file:
            new_file.writelines(new_file_lines)

        # overwrite the original file
        copy(path_to_new_file, "/mnt/etc/locale.gen")


def _create_locale_conf_file(locale_dict):
    """Creates /mnt/etc/locale.conf based on the locale dict."""

    with open("/mnt/etc/locale.conf", "w") as file:
        file_lines = [
            "# Generated by asap", "\n", "\n",
        ]
        for key, value in locale_dict.items():
            file_lines.append(f"{key}={value}\n")
        file.writelines(file_lines)


def configure_locale():
    """Generates and sets the locale according to the config file."""

    CONFIG = load_config()
    if "locale" in CONFIG:
        locale = CONFIG["locale"]
        if not isinstance(locale, dict):
            raise InvalidConfigFileError(
                "Config key 'locale' must contain key-value pairs."
            )
        valid_keys = [
            "LANG",
            "LC_CTYPE",
            "LC_NUMERIC",
            "LC_TIME",
            "LC_COLLATE",
            "LC_MONETARY",
            "LC_MESSAGES",
            "LC_PAPER",
            "LC_NAME",
            "LC_ADDRESS",
            "LC_TELEPHONE",
            "LC_MEASUREMENT",
            "LC_IDENTIFICATION",
        ]
        for key, value in locale.items():
            if not key in valid_keys:
                raise InvalidConfigFileError(
                    f"Invalid locale variable: '{key}'."
                )
            if not isinstance(value, str):
                raise InvalidConfigFileError(
                    f"Value for locale key '{key}' must be a string."
                )
        # make sure the LANG variable is set
        if "LANG" not in locale:
            raise InvalidConfigFileError(
                "Config has a locale entry, but no 'LANG' was specified."
            )
    else:
        # set the default locale to 'en_US.UTF8'
        locale = {"LANG": "en_US.UTF8"}

    # run locale-gen
    logging.info("Generating locales...")
    _modify_locale_gen_file(locale)
    run(
        [
            "arch-chroot", "/mnt",
            "locale-gen",
        ],
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=True,
    )
    _create_locale_conf_file(locale)
    logging.info("The locales were generated.")


def set_console():
    """Sets the keymap and consolefont according to the config file."""

    CONFIG = load_config()
    if not "console" in CONFIG:
        return
    else:
        console = CONFIG["console"]
        if not isinstance(console, dict):
            raise InvalidConfigFileError(
                "Config value for 'console' must be a dict."
            )
        if "keymap" in console:
            keymap = console["keymap"]
            if not isinstance(keymap, str):
                raise InvalidConfigFileError(
                    "Value for config key 'keymap' must be a string."
                )
        else:
            keymap = None
        if "font" in console:
            font = console["font"]
            if not isinstance(font, str):
                raise InvalidConfigFileError(
                    "Value for config key 'font' must be a string."
                )
        else:
            font = None

    # create vconsole.conf
    file_lines = []
    if keymap is not None:
        file_lines.append(f"KEYMAP={keymap}")
    if font is not None:
        file_lines.append(f"FONT={font}")

    if len(file_lines) > 0:
        logging.info("Setting console settings...")
        with open("/mnt/etc/vconsole.conf", "w") as file:
            for line in file_lines:
                file.write(line + "\n")
        logging.info("The console settings were set.")


def set_hostname():
    """Sets the hostname according to the config file."""

    CONFIG = load_config()
    if "hostname" not in CONFIG:
        raise InvalidConfigFileError(
            "Config key 'hostname' is missing from config."
        )
    hostname = CONFIG["hostname"]
    if not isinstance(hostname, str):
        raise InvalidConfigFileError(
            "Config key 'hostname' must be a string."
        )

    if "domainname" in CONFIG:
        domainname = CONFIG["domainname"]
        if not isinstance(domainname, str):
            raise InvalidConfigFileError(
                "Config key 'domainname' must be a string."
            )
    else:
        domainname = None

    # create /mnt/etc/hostname
    logging.info("Setting hostname...")
    with open("/mnt/etc/hostname", "w") as hostname_file:
        hostname_file.write(f"{hostname}\n")

    # create /mnt/etc/hosts
    hosts_file_lines = [
        "127.0.0.1", "\t", "localhost", "\n",
        "::1", "\t\t", "localhost", "\n",
        "127.0.1.1", "\t",
        f"{hostname}.{domainname} {hostname}" if domainname is not None else f"{hostname}", "\n",
    ]
    with open("/mnt/etc/hosts", "w") as hosts_file:
        hosts_file.writelines(hosts_file_lines)

    logging.info("The hostname was set.")


def enable_network_service():
    """Enables the dhcpcd or network manager service if possible."""

    CONFIG = load_config()
    if "networkmanager" in CONFIG["packages"]:
        service_name = "NetworkManager"
    elif "dhcpcd" in CONFIG["packages"]:
        service_name = "dhcpcd"
    else:
        logging.warning("No DHCP service seems to be installed on the target system.")
        logging.warning("Networking may not work properly after rebooting.")
        return

    logging.info("Enabling DHCP service...")
    run(
        [
            "arch-chroot", "/mnt",
            "systemctl", "enable", f"{service_name}",
        ],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )
    logging.info("The DHCP service was enabled.")


def set_root_password():
    """Shows a prompt to set the root password."""

    logging.info("Setting root password...")
    run(
        [
            "arch-chroot", "/mnt",
            "passwd", "root"
        ],
        stdin=sys.stdin,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=True,
    )
    logging.info("The root password was set.")


def add_sudo_config():
    """Adds a custom sudo configuration to /mnt/etc/sudoers.d/10-default"""

    logging.info("Adding sudo configuration...")
    # create file
    path_to_sudo_config = Path("/mnt/etc/sudoers.d/10-default")
    with open(path_to_sudo_config, "w") as file:
        file.write(
            "# Allow members of group wheel to execute any command:\n"
            "%wheel ALL=(ALL:ALL) ALL\n"
        )
    # chmod to 'r--r-----'
    path_to_sudo_config.chmod(0o440)
    logging.info("The sudo configuration was added.")


def create_non_root_user():
    """Creates a non root user."""

    CONFIG = load_config()
    if "user" not in CONFIG:
        return
    username = CONFIG["user"]
    if not isinstance(username, str):
        raise InvalidConfigFileError(
            "Config key 'user' must hold a string value."
        )

    logging.info(f"Creating user '{username}'...")
    # create the user
    run(
        [
            "arch-chroot", "/mnt",
            "useradd", "--create-home", "--user-group",
            "--groups", "wheel",
            username
        ],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )
    logging.info(f"The user '{username}' was created.")


def set_non_root_user_password():
    """Creates a non root user."""

    CONFIG = load_config()
    if "user" not in CONFIG:
        return
    username = CONFIG["user"]
    if not isinstance(username, str):
        raise InvalidConfigFileError(
            "Config key 'user' must hold a string value."
        )

    logging.info(f"Setting password for user '{username}'...")
    # prompt for the user's password
    run(
        [
            "arch-chroot", "/mnt",
            "passwd", username,
        ],
        stdin=sys.stdin,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=True,
    )
    logging.info(f"Password for user '{username}' was set.")


def init_pacman_keyring_target():
    """Initializes the pacman keyring on the target system."""

    logging.info("Populating pacman keyring (this might take a while)...")

    run(
        [
            "arch-chroot", "/mnt",
            "pacman-key", "--init"
        ],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )
    run(
        [
            "arch-chroot", "/mnt",
            "pacman-key", "--populate", "archlinux"
        ],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )
    run(
        [
            "arch-chroot", "/mnt",
            "pacman-key", "--refresh-keys",
        ],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )
    logging.info("Pacman keyring was populated.")


def install_grub():
    """Installs grub to /mnt/boot."""

    logging.info("Installing grub...")
    run(
        [
            "arch-chroot", "/mnt",
            "grub-install", "--target=x86_64-efi", "--efi-directory=/boot",
            "--bootloader-id=GRUB", "--recheck",
        ],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )
    run(
        [
            "arch-chroot", "/mnt",
            "grub-mkconfig", "-o", "/boot/grub/grub.cfg",
        ],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )
    logging.info("Grub was installed.")


def configure_mkinitcpio():
    """Adds some hooks to /mnt/etc/mkinitcpio.conf"""

    CONFIG = load_config()
    if not "mkinitcpio" in CONFIG:
        raise InvalidConfigFileError(
            "Key 'mkinitcpio' missing from configuration."
        )
    if not isinstance(CONFIG["mkinitcpio"], dict):
        raise InvalidConfigFileError(
            "Config entry 'mkinitcpio' must be a dict."
        )
    if not "hooks" in CONFIG["mkinitcpio"]:
        raise InvalidConfigFileError(
            "Key 'hooks' is missing from 'mkinitcpio' in config."
        )
    hooks = CONFIG["mkinitcpio"]["hooks"]
    if not isinstance(hooks, list):
        raise InvalidConfigFileError(
            "Config entry 'mkinitcpio' -> 'hooks' must be a list."
        )
    for hook in hooks:
        if not isinstance(hook, str):
            raise InvalidConfigFileError(
                "Config entries in 'mkinitcpio' -> 'hooks' must be strings."
            )

    mkinitcpio_hooks_string = " ".join(hooks)
    mkinitcpio_hooks_line = f"HOOKS=({mkinitcpio_hooks_string})\n"

    # replace /mnt/etc/mkinitcpio.conf
    logging.info("Modifying mkinitcpio configuration...")
    with TemporaryDirectory() as tmp_dir:
        path_to_tmp_dir = Path(tmp_dir)
        path_to_file_copy = path_to_tmp_dir / Path("mkinitcpio.conf")
        # copy all lines but replace the HOOKS line
        with open(path_to_file_copy, "w") as file_copy:
            file_copy_lines = []
            with open("/mnt/etc/mkinitcpio.conf", "r") as file_orig:
                for line in file_orig.readlines():
                    if line.startswith("HOOKS="):
                        file_copy_lines.append(mkinitcpio_hooks_line)
                    else:
                        file_copy_lines.append(line)
            file_copy.writelines(file_copy_lines)
        # overwrite the original file
        copy(path_to_file_copy, "/mnt/etc/mkinitcpio.conf")
    logging.info("Mkinitcpio configuration was modified.")


def regenerate_initramfs():
    """Rebuilds the target system's initramfs using mkinitcpio."""

    logging.info("Rebuilding initial RAM filesystem...")
    run(
        [
            "arch-chroot", "/mnt",
            "mkinitcpio", "-P",
        ],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )
    logging.info("Initial RAM filesystem was rebuilt.")


def harden_sshd():
    """Installs a hardened SSH-Daemon config to the target system."""

    CONFIG = load_config()
    if not "user" in CONFIG:
        raise InvalidConfigFileError(
            "Key 'user' is missing from config file."
        )
    username = CONFIG["user"]
    if not isinstance(username, str):
        raise InvalidConfigFileError(
            "Config value for key 'user' must be a string."
        )

    # append inclusion directory to sshd config
    logging.info("Installing hardened SSH daemon configuration...")
    with open("/mnt/etc/ssh/sshd_config", "a") as file:
        file.writelines(
            [
                "\n",
                "# Include custom configuration files", "\n",
                "Include /etc/ssh/sshd_config.d/*.conf", "\n"
            ]
        )
    # create sshd inclusion directory
    Path("/mnt/etc/ssh/sshd_config.d").mkdir()

    sshd_config_contents = [
        "##### hardened sshd config #####",
        "#",
        "# source: https://stribika.github.io/2015/01/04/secure-secure-shell.html",
        "#",
        "# use 'ssh-keygen -t ed25519 -o -a 100' or 'ssh-keygen -t rsa -b 4096 -o -a 100' to generate client",
        "# keys",
        "",
        "# port number",
        "Port 22",
        "# IPv4 only",
        "AddressFamily inet",
        "# restrict address to listen on",
        "#ListenAddress 0.0.0.0",
        "",
        "# banner file to show upon login",
        "Banner none",
        "",
        "# disable X11 forwarding",
        "X11Forwarding no",
        "",
        "# restrict to these users",
        f"AllowUsers {username}",
        "PermitRootLogin no",
        "",
        "# restrict to these authentication methods",
        "AuthenticationMethods publickey",
        "PubkeyAuthentication yes",
        "",
        "# maximum number of authentication attempts per connection",
        "MaxAuthTries 6",
        "",
        "# disable all of these authentication methods",
        "PasswordAuthentication no",
        "ChallengeResponseAuthentication no",
        "KbdInteractiveAuthentication no",
        "GSSAPIAuthentication no",
        "HostbasedAuthentication no",
        "KerberosAuthentication no",
        "",
        "# allowed key exhange protocols",
        "KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256",
        "# allowed connection ciphers",
        "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr",
        "# allowed host keys",
        "HostKey /etc/ssh/ssh_host_ed25519_key",
        "HostKey /etc/ssh/ssh_host_rsa_key",
        "# allowed message authentication codes",
        "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com",
    ]

    # add custom sshd config file
    with open("/mnt/etc/ssh/sshd_config.d/10-hardened.conf", "w") as file:
        for line in sshd_config_contents:
            file.write(line + "\n")

    logging.info("Hardened SSH daemon configuration was installed.")


def enable_sshd_service():
    """Enables the SSHD service on the target machine."""

    logging.info("Enabling the SSH server...")
    run(
        [
            "arch-chroot", "/mnt",
            "systemctl", "enable", "sshd",
        ],
        stdout=DEVNULL,
        stderr=DEVNULL,
        check=True,
    )
    logging.info("SSH server was enabled.")


def copy_ssh_keyfile():
    """Copies the ISO's SSH authorized_keys file to the non-root user."""

    CONFIG = load_config()
    if not "user" in CONFIG:
        raise InvalidConfigFileError(
            "Key 'user' is missing from config file."
        )
    username = CONFIG["user"]
    if not isinstance(username, str):
        raise InvalidConfigFileError(
            "Config value for key 'user' must be a string."
        )

    path_to_keys_file = Path("/root/.ssh/authorized_keys")
    if not path_to_keys_file.parent.exists():
        return
    if not path_to_keys_file.exists():
        return
    if not path_to_keys_file.is_file():
        raise RuntimeError(f"Expected a file: {path_to_keys_file}")

    logging.info("Transferring SSH authorized keys...")

    # create the user ssh directory
    path_to_ssh_dir = Path(f"/mnt/home/{username}/.ssh")
    path_to_ssh_dir.mkdir(mode=0o700)
    chown(path_to_ssh_dir, user=1000, group=1000)

    path_to_user_file = Path(f"/mnt/home/{username}/.ssh/authorized_keys")
    copy(path_to_keys_file, path_to_user_file)
    path_to_user_file.chmod(0o644)
    chown(path_to_user_file, user=1000, group=1000)

    logging.info("SSH authorized keys were transferred.")


def install_paru():
    """Installs the paru AUR helper on the target system."""

    CONFIG = load_config()

    if not "install_paru" in CONFIG:
        return
    if not isinstance(CONFIG["install_paru"], bool):
        raise InvalidConfigFileError(
            "Value for config key 'install_paru' must be a boolean."
        )
    if not CONFIG["install_paru"]:
        return

    if not "user" in CONFIG:
        raise InvalidConfigFileError(
            "Key 'user' is missing from config file."
        )
    username = CONFIG["user"]
    if not isinstance(username, str):
        raise InvalidConfigFileError(
            "Config value for key 'user' must be a string."
        )

    logging.info("Installing paru...")

    # create a system-wide paru config file
    with open("/mnt/etc/paru.conf", "w") as file:
        lines = [
            "# paru configuration file",
            "# generated by asap",
            "# See the paru.conf(5) manpage for options",
            "",
            "#",
            "# GENERAL OPTIONS",
            "#",
            "[options]",
            "PgpFetch",
            "Devel",
            "Provides",
            "DevelSuffixes = -git -cvs -svn -bzr -darcs -always -hg -fossil",
            "RemoveMake",
            "SudoLoop",
            "CleanAfter",
        ]
        for line in lines:
            file.write(line + "\n")

    # create a paru installation script in the user's home directory
    with open(f"/mnt/home/{username}/install-paru.sh", "w") as file:
        lines = [
            "#!/bin/sh",
            "# paru AUR helper installation script",
            "# Generated by asap",
            f"sudo -u {username} git clone https://aur.archlinux.org/paru.git /home/{username}/paru",
            f"cd /home/{username}/paru",
            f"sudo -u {username} makepkg -scirf",
            f"cd /home/{username}",
            f"sudo -u {username} rm -rf /home/{username}/paru",
            f"sudo -u {username} paru -Syu",
            f"sudo -u {username} paru -S paru",
        ]
        for line in lines:
            file.write(line + "\n")

    # call the created installation script
    run(
        [
            "arch-chroot", "-u", username, "/mnt",
            "sh", f"/home/{username}/install-paru.sh",
        ],
        stdin=sys.stdin,
        stdout=sys.stdout,
        stderr=sys.stderr,
        check=True,
    )
    # remove the created installation script
    Path(f"/mnt/home/{username}/install-paru.sh").unlink()

    logging.info("Paru was installed.")


stage = Stage(
    "Install and configure the target system.",
    [
        Step("Generate pacman mirrorlist", generate_mirrorlist),
        Step("Initialize pacman keyring (ISO)", init_pacman_keyring_iso),
        Step("Install packages", pacstrap),
        Step("Set the timezone", set_timezone),
        Step("Sync the hardware clock", sync_hardware_clock),
        Step("Configure locale", configure_locale),
        Step("Set console settings", set_console),
        Step("Set hostname", set_hostname),
        Step("Enable DHCP", enable_network_service),
        Step("Set root password", set_root_password),
        Step("Modify sudo configuration", add_sudo_config),
        Step("Create non-root user", create_non_root_user),
        Step("Set non-root user's password", set_non_root_user_password),
        Step("Initialize pacman keyring (target)", init_pacman_keyring_target),
        Step("Install GRUB", install_grub),
        Step("Configure mkinitcpio", configure_mkinitcpio),
        Step("Regenerate initramfs", regenerate_initramfs),
        Step("Harden SSHD", harden_sshd),
        Step("Enable SSH server", enable_sshd_service),
        Step("Copy SSH authorized keys", copy_ssh_keyfile),
        Step("Install paru", install_paru),
    ]
)
