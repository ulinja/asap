"""This module handles the parsing of commandline arguments."""

from argparse import ArgumentParser


def get_argument_parser():
    """Sets up an ArgumentParser and returns it."""

    mainparser = ArgumentParser(
        description="Automated Arch Linux installer.",
    )

    # add mainparser arguments
    mainparser.add_argument(
        "--debug",
        action="store_true",
        help="Display debugging log messages.",
    )

    # register subparsers for the 'run' and 'info' subcommands
    subparsers = mainparser.add_subparsers(
        required=True,
        title="Subcommands",
        description="A choice of actions you want asap to take",
        help="You must specify one of these",
        dest="subparser_name",
    )
    subparser_run = subparsers.add_parser(
        "run",
        description="Run the asap installer.",
    )
    subparser_info = subparsers.add_parser(
        "info",
        description="Show information about the current installation state.",
    )

    # TODO register arguments for the 'run' subcommand

    # register arguments for the 'info' subcommand
    subparser_info.add_argument(
        "WHAT",
        choices=["checkpoints", "config"],
        action="store",
        type=str,
        metavar="WHAT",
        help="The type of information to show: 'checkpoints' to view the "
        "current checkpoints, or 'config' to view the current configuration.",
    )

    return mainparser
