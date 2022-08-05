"""This module handles the loading of global configuration values.

The global configuration is loaded from the asap configuration file, which is
written in yaml. Configuration values are loaded into a dict called CONFIG,
which is in the global namespace of this module.
"""

from pathlib import Path
import logging

from yaml import YAMLError, load, dump
try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


# TODO set this to a proper value
_default_path_to_config_file = Path("/tmp/asap/target.yml")
#_default_path_to_config_file = Path("/etc/asap/target.yml")

# create the global configuration dict
CONFIG = {}


class InvalidConfigFileError(RuntimeError):
    """Raised when a configuration files' contents are invalid."""


def load_config(path_to_config_file=_default_path_to_config_file):
    """Loads the specified file's contents into the global CONFIG variable.

    The specified config file must contain valid yaml syntax.

    Parameters
    ----------
    path_to_config_file : str or pathlike object
        The path to the configuration file to be loaded.

    Returns
    -------
    None

    Raises
    ------
    InvalidConfigFileError
        If the configuration file could not be parsed correctly due to having
        invalid or unexpected contents.
    """

    path_to_config_file = Path(path_to_config_file).expanduser().resolve()
    if not path_to_config_file.is_file():
        raise FileNotFoundError(f"No such file: '{path_to_config_file}'.")

    with open(path_to_config_file, "r") as config_file:
        try:
            config = load(config_file, Loader=Loader)
        except YAMLError as exception:
            raise InvalidConfigFileError(
                f"Failed to parse config file '{path_to_config_file}' "
                f"as valid yaml."
            ) from exception

    # TODO validate config contents!

    CONFIG = config
