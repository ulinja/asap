#!/usr/bin/env python3
"""Main entry point for the asap CLI tool."""

from sys import exit
import logging
import json

from core.parser import get_argument_parser
from core.config import load_config
from core.staging import AbstractStep
import core.serialization as sz
import stages.stage1 as s1
import stages.stage2 as s2
import stages.stage3 as s3


STAGES = [s1.stage, s2.stage, s3.stage]


def main():
    # create an argument parser and read arguments
    parser = get_argument_parser()
    args = parser.parse_args()

    # set up logging
    logging.basicConfig(
        format="[%(levelname)-8s] %(message)s",
        level=logging.DEBUG if args.debug else logging.INFO,
    )

    # load the config file
    CONFIG = load_config()

    # check for existence of the checkpoint file
    if sz.path_to_checkpoint_file.is_file():
        # load checkpoints if checkpoint file exists
        sz.load_checkpoints(STAGES)
    else:
        # otherwise create a new checkpoint file
        sz.save_checkpoints(STAGES)

    if args.subparser_name == "info":
        if args.WHAT == "checkpoints":
            # display contents of the checkpoint file
            with open(sz.path_to_checkpoint_file, "r") as file:
                print(json.dumps(json.load(file), indent=2))
            exit()
        elif args.WHAT == "config":
            # display the configuration
            print(json.dumps(CONFIG, indent=2))
            exit()

    elif args.subparser_name == "run":
        # execute all stages
        for stage in STAGES:
            try:
                stage.execute()
            except AbstractStep.ExecutionFailedError as exception:
                logging.critical(f"Aborting: {str(exception)}")
                logging.info("You can try to fix the problem and re-run asap to continue.")
                exit(1)
            finally:
                sz.save_checkpoints(STAGES)

        logging.info("Finished.")

        exit()

if __name__ == '__main__':
    main()
