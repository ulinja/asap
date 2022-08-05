#!/usr/bin/env python3
"""Main entry point for the asap CLI tool."""

from sys import exit
import logging
import json

from core.parser import get_argument_parser
from core.config import load_config
import core.serialization as sz


def main():
    # create an argument parser and read arguments
    parser = get_argument_parser()
    args = parser.parse_args()

    # set up logging
    logging.basicConfig(
        format="[%(levelname)s]\t%(message)s",
        level=logging.DEBUG if args.debug else logging.INFO,
    )

    # load the config file
    if args.config:
        CONFIG = load_config(args.config)
    else:
        CONFIG = load_config()

    if args.subparser_name == "info":
        if args.WHAT == "checkpoints":
            # display contents of the checkpoint file
            if not sz.path_to_checkpoint_file.is_file():
                logging.info("No checkpoint file exists yet.")
            else:
                with open(sz.path_to_checkpoint_file, "r") as file:
                    print(json.dumps(json.load(file), indent=2))
            exit()
        elif args.WHAT == "config":
            # display contents of the configuration file
            print(json.dumps(CONFIG, indent=2))
            exit()

    elif args.subparser_name == "run":
        # TODO begin installation
        exit()

if __name__ == '__main__':
    main()
