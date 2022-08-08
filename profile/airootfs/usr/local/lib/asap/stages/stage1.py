"""This module verifies the installation medium's environment."""

from pathlib import Path
from subprocess import CalledProcessError, DEVNULL, run
import logging

from core.config import load_config
from core.staging import Step, Stage


def assert_boot_mode_is_correct():
    """Asserts that the installation medium was booted in UEFI-mode.

    https://wiki.archlinux.org/title/Installation_guide#Verify_the_boot_mode

    Raises
    ------
    NotADirectoryError
        If the efivars directory does not exist (i.e. the live system booted in
        BIOS mode)
    """

    logging.info("Verifying boot mode...")
    path_to_efivars_dir = Path("/sys/firmware/efi/efivars")
    try:
        if not path_to_efivars_dir.is_dir():
            raise NotADirectoryError(
                "The installation medium is not booted in UEFI mode."
            )
    except OSError:
        # running stat on the efivars dir throws an OSError if it doesnt exist
        raise NotADirectoryError(
            "The installation medium is not booted in UEFI mode."
        )
    logging.info("Live medium is booted in UEFI mode.")

def assert_has_internet_connectivity():
    """Asserts that the system has internet connectivity.

    Raises
    ------
    RuntimeError
        If there is no active internet connection.
    """

    logging.info("Verifying internet connectivity...")
    try:
        run(
            ["ping", "-W", "10", "-c", "3", "archlinux.org"],
            check=True,
            stdout=DEVNULL,
            stderr=DEVNULL,
        )
    except CalledProcessError:
        raise RuntimeError("System does not have internet connectivity.")
    logging.info("System has internet connectivity.")


def enable_chroot_dns():
    """Creates a symlink to systemd-resolved's resolv.conf.

    This is done to enable a working DNS later on in the arch-chroot.
    """

    # remove exitsing /etc/resolv.conf
    # and replace it with a symlink to /run/systemd/resolve/resolv.conf
    logging.info("Linking DNS configuration...")
    path_to_etc_resolv_conf = Path("/etc/resolv.conf")
    path_to_etc_resolv_conf.unlink(missing_ok=True)
    path_to_etc_resolv_conf.symlink_to("/run/systemd/resolve/resolv.conf")
    logging.info("DNS configuration was linked.")


def enable_ntp_sync():
    """Enables systemd NTP synchronization.

    Raises
    ------
    RuntimeError
        If the call to timedatectl fails.
    """

    logging.info("Enabling system clock synchronization.")
    try:
        run(
            ["timedatectl", "set-ntp", "true"],
            check=True,
            stdout=DEVNULL,
            stderr=DEVNULL,
        )
    except CalledProcessError:
        raise RuntimeError("Failed to enable NTP using timedatectl.")


stage = Stage(
    "Initialize the installation environment",
    [
        Step("Verify UEFI boot mode", assert_boot_mode_is_correct),
        Step("Verify internet connectivity", assert_has_internet_connectivity),
        Step("Link DNS configuration", enable_chroot_dns),
        Step("Enable NTP synchronization", enable_ntp_sync),
    ]
)
