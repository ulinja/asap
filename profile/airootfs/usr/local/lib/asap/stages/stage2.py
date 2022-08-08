"""This module handles creation and mounting of disk partitions.

Depending on the value of 'auto_partition' set in the CONFIG, the user is
either prompted to carry out each step in this stage manually, or asap
performs a "dumb" auto-partitioning of the drive at /dev/sda.
ALL DATA ON /dev/sda IS IRREVOCABLY WIPED if auto-partitioning is used.
"""

from pathlib import Path
from subprocess import CalledProcessError, DEVNULL, STDOUT, PIPE, run
from sys import exit
import logging

from core.config import load_config, InvalidConfigFileError
from core.staging import Step, Stage
from core.utils import prompt_yes_or_no



def auto_partitioning_is_enabled():
    """Checks whether auto-partitioning is enabled in the config file."""

    CONFIG = load_config()
    if "auto_partition" in CONFIG:
        if not isinstance(CONFIG["auto_partition"], bool):
            raise InvalidConfigFileError(
                f"Unrecognized value in config for key 'auto_partition': "
                f"expected a boolean value"
            )

        use_auto_partitioning = CONFIG["auto_partition"]
    else:
        # default to no
        use_auto_partitioning = False

    return use_auto_partitioning


def confirm_partitioning_method():
    """Prompts the user for confirmation of the configured partitioning method.

    Prompts the user for confirmation prior to performing auto-partitioning if
    it is enabled in the CONFIG.
    If auto-partitioning is disabled in the CONFIG, prints a message informing
    the user about the steps they need to perform manually.
    """

    if auto_partitioning_is_enabled():
        # prompt user for confirmation of auto-partitioning
        logging.warning(
            "You have enabled auto-partitioning in your configuration."
        )
        logging.warning(
            "Auto-partitioning will irrevocably erase all data on '/dev/sda'!"
        )
        if prompt_yes_or_no(
                "Are you sure you want to continue?", ask_until_valid=True
        ):
            return
        else:
            raise RuntimeError(
                "Please adjust your configuration if you want to disable "
                "auto-partitioning."
            )
    else:
        # inform user about manual partitioning steps
        logging.info(
            "You have disabled auto-partitioning in your configuration."
        )
        logging.info(
            "Before continuing, you must partition and format your drives "
            "yourself."
            )
        logging.info(
            "Mount the root partition at '/mnt' and all other "
            "partitions at their appropriate mount point within '/mnt/'."
        )
        logging.info(
            "Create an fstab-file at '/mnt/etc/fstab' appropriately."
        )
        logging.info(
            "Don't forget to also create a crypttab-file if necessary."
        )
        logging.info(
            "Once all this is done, you can continue the installation with "
            "'asap run'."
        )
        input("[PROMPT  ] Press ENTER to continue...")
        exit(0)


def create_partitions():
    """Creates a standard partitioning scheme on /dev/sda.

    Raises
    ------
    RuntimeError
        If the partitioning process fails.
    """

    if not auto_partitioning_is_enabled():
        if prompt_yes_or_no(
                "Did you create your partitions?", ask_until_valid=True
        ):
            return
        else:
            raise RuntimeError("Please create your partitions before continuing.")
    else:
        logging.info("Creating partitions...")
        try:
            run(
                [
                    "parted", "--script", "--align", "optimal",
                    "/dev/sda", "--",
                    "mklabel", "gpt",
                    "mkpart", "EFI", "fat32", "1MiB", "513MiB",
                    "mkpart", "LVM", "513MiB", "-1",
                    "set", "1", "esp", "on",
                    "set", "2", "lvm", "on"
                ],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
        except CalledProcessError:
            raise RuntimeError("Failed to create partitions. Are there active LVM LVs/VGs/PVs?")
        logging.info("Partitions were created.")


def create_filesystems():
    """Creates the necessary filesystems on the standard partitioning scheme.

    Raises
    ------
    RuntimeError
        If the formatting process fails.
    """

    if not auto_partitioning_is_enabled():
        if prompt_yes_or_no(
                "Did you format your partitions?", ask_until_valid=True
        ):
            return
        else:
            raise RuntimeError("Please format your partitions before continuing.")
    else:
        logging.info("Creating filesystems...")
        try:
            # format the EFI partition
            run(
                ["mkfs.fat", "-F", "32", "-n", "BOOT", "/dev/sda1"],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
            # set up LVM on the second partition
            run(
                ["pvcreate", "/dev/sda2"],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
            run(
                ["vgcreate", "vg0", "/dev/sda2", "--yes"],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
            run(
                ["lvcreate", "--yes", "-L", "1G", "vg0", "-n", "swap"],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
            run(
                ["lvcreate", "--yes", "-l", "100%FREE", "vg0", "-n", "root"],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
            # format the LVs
            run(
                ["mkswap", "-L", "SWAP", "/dev/vg0/swap"],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
            run(
                ["mkfs.ext4", "-L", "ROOT", "/dev/vg0/root"],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
        except CalledProcessError:
            raise RuntimeError("Failed to create partitions.")
        logging.info("Partitions were created.")


def mount_filesystems():
    """Mounts the filesystems which were auto-generated."""

    if not auto_partitioning_is_enabled():
        if prompt_yes_or_no(
                "Did you mount your partitions?", ask_until_valid=True
        ):
            return
        else:
            raise RuntimeError("Please mount your partitions before continuing.")
    else:
        logging.info("Mounting filesystems...")
        try:
            run(
                ["mount", "/dev/vg0/root", "/mnt"],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
            Path("/mnt/boot").mkdir()
            run(
                ["mount", "/dev/sda1", "/mnt/boot"],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
            run(
                ["swapon", "/dev/vg0/swap"],
                check=True,
                stdout=DEVNULL,
                stderr=DEVNULL,
            )
        except CalledProcessError:
            raise RuntimeError("Failed to mount filesystems.")
        logging.info("Filesystems were mounted.")


def generate_fstab():
    """Generates the fstab file based on the automatic partitioning."""

    if not auto_partitioning_is_enabled():
        if prompt_yes_or_no(
                "Did you create an fstab-file?", ask_until_valid=True
        ):
            return
        else:
            raise RuntimeError("Please create an fstab-file before continuing.")
    else:
        logging.info("Generating filesystem table...")
        try:
            boot_fs_uuid = run(
                ["blkid", "/dev/sda1"],
                stdout=PIPE,
                stderr=STDOUT,
                text=True,
                check=True,
            ).stdout.split()[3][6:-1]

            root_fs_uuid = run(
                ["blkid", "/dev/vg0/root"],
                stdout=PIPE,
                stderr=STDOUT,
                text=True,
                check=True,
            ).stdout.split()[2][6:-1]

            swap_fs_uuid = run(
                ["blkid", "/dev/vg0/swap"],
                stdout=PIPE,
                stderr=STDOUT,
                text=True,
                check=True,
            ).stdout.split()[2][6:-1]
        except CalledProcessError:
            raise RuntimeError("Failed to read partition UUIDs.")

        fstab_file_lines = [
            "# Generated by ASAP", "\n",
            f"UUID={root_fs_uuid} / ext4 rw,relatime 0 1", "\n"
            f"UUID={boot_fs_uuid} /boot vfat rw,relatime,fmask=0022,dmask=0022,"
            f"codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro "
            f"0 2", "\n"
            f"UUID={swap_fs_uuid} none swap defaults 0 0", "\n"
        ]

        if not Path("/mnt/etc").is_dir():
            Path("/mnt/etc").mkdir()
        with open("/mnt/etc/fstab", "w") as fstab_file:
            fstab_file.writelines(fstab_file_lines)

        logging.info("Filesystem table was generated.")

stage = Stage(
    "Partitioning and filesystem creation",
    [
        Step("Confirm partitioning method", confirm_partitioning_method),
        Step("Create partitions", create_partitions),
        Step("Create filesystems", create_filesystems),
        Step("Mount filesystems", mount_filesystems),
        Step("Generate filesystem table", generate_fstab),
    ]
)
