"""This module handles the file (de-)serialization of Checkpoint states."""

from pathlib import Path
import json
import logging

from core.staging import Stage, CheckpointState


path_to_checkpoint_file = Path("/var/cache/asap/checkpoints.json")

class FileFormatError(RuntimeError):
    """Raised when a text file's contents have an invalid format."""


def save_checkpoints(
        list_of_stages,
        path_to_checkpoint_file=path_to_checkpoint_file
):
    """Saves the checkpoints of the input stages to the specified file.

    The output file is created if it does not exist and gets replaced if it
    does exist.
    The output file is in JSON format, containing all Stages and their
    respective Steps and their checkpoint statuses:
    {
      "stage_name": {
        "status": "stage_checkpoint_status",
        "steps": {
          "step_name": "step_checkpoint_status",
          ...
        }
      },
      ...
    }
    """

    path_to_checkpoint_file = Path(path_to_checkpoint_file).expanduser().resolve()
    if not path_to_checkpoint_file.parent.is_dir():
        raise NotADirectoryError(
            f"No such directory: '{path_to_checkpoint_file.parent}'."
        )

    if not isinstance(list_of_stages, list):
        raise TypeError(f"Expected a {list}.")

    # create the output file contents as a dict
    output_file_contents = dict()
    for stage in list_of_stages:
        if not isinstance(stage, Stage):
            raise TypeError(f"Expected a {Stage}.")

        output_file_contents[stage.name] = {
            "status": stage.checkpoint.state.name,
            "steps": {
                name: step.checkpoint.state.name for (name, step) in stage.steps.items()
            }
        }

    # write the output file
    with open(path_to_checkpoint_file, "w") as output_file:
        json.dump(output_file_contents, output_file, indent=2)


def load_checkpoints(
        list_of_stages,
        path_to_checkpoint_file=path_to_checkpoint_file
):
    """Loads the checkpoints from the specified file into the stages."""

    path_to_checkpoint_file = Path(path_to_checkpoint_file).expanduser().resolve()
    if not path_to_checkpoint_file.is_file():
        raise FileNotFoundError(
            f"No such file: '{path_to_checkpoint_file}'."
        )

    if not isinstance(list_of_stages, list):
        raise TypeError(f"Expected a {list}.")
    for stage in list_of_stages:
        if not isinstance(stage, Stage):
            raise TypeError(f"Expected a {Stage}.")


    with open(path_to_checkpoint_file, "r") as checkpoint_file:
        stage_states = json.load(checkpoint_file)

    # ensure the stage count is correct
    if len(stage_states) != len(list_of_stages):
        raise ValueError(
            f"Inconsistent number of stages checkpoint file: "
            f"expected {len(list_of_stages)} but got {len(stage_states)}."
        )
    # ensure the checkpoint file content's structure is correct
    for stage_name, stage_dict in stage_states.items():
        if not stage_name in [stage.name for stage in list_of_stages]:
            raise ValueError(
                f"Unexpected stage name in checkpoint file: '{stage_name}'."
            )
        if len(stage_dict) != 2:
            raise FileFormatError(
                f"Invalid number of keys in stage object."
            )
        for key in ["status", "steps"]:
            if key not in stage_dict:
                raise FileFormatError(f"Missing key in stage object: '{key}'.")
        try:
            CheckpointState[stage_dict["status"]]
        except KeyError as exception:
            raise FileFormatError(
                "Invalid value for Stage status in checkpoint file: "
                "'{}'.".format(stage_dict["status"])
            ) from exception

    # load the checkpoints into each stage
    for stage in list_of_stages:
        stage_status = stage_states[stage.name]["status"]
        stage_steps = stage_states[stage.name]["steps"]
        stage.checkpoint.state = CheckpointState[stage_status]
        stage.set_checkpoint_states(stage_steps)
