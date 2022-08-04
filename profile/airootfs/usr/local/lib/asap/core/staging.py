"""This module defines installation stages and checkpoints."""

from abc import ABC, abstractmethod
from enum import Enum, unique


@unique
class CheckpointState(Enum):
    """The completion state of a checkpoint.

    Checkpoints can have three possible completion states:
    - NOT_STARTED: the Step for this checkpoint has never been attempted before
    - FAILED: the Step for this checkpoint has been attempted before and failed
    - SUCCEEDED: the Step for this checkpoint has been successfully executed
    """

    NOT_STARTED = "not_started"
    FAILED = "failed"
    SUCCEEDED = "succeeded"


class Checkpoint:
    """A checkpoint represents a serializable state of an installation step.
    """

    def __init__(self, state=None):
        if state is not None:
            if not isinstance(state, CheckpointState):
                raise TypeError(f"Expected a {CheckpointState}.")
            self.state = state
        else:
            self.state = CheckpointState.NOT_STARTED

    def set_failed(self):
        """Set this Checkpoint's state to FAILED."""

        self.state = CheckpointState.FAILED

    def set_succeeded(self):
        """Set this Checkpoint's state to SUCCEEDED."""

        self.state = CheckpointState.SUCCEEDED


class AbstractStep(ABC):
    """A abstract class representing named step in a sequential process.

    The object represented by this class (a Step or a Stage) can be executed
    by invoking the execute() method.
    The object has a name property which is a non-empty string.
    The success state of the most recent execution is saved in the form of a
    Checkpoint.
    If the execution of the object has never been attempted, the Checkpoint is
    in the NOT_STARTED state.
    If something fails during the execution of the object, its Checkpoint's
    state should be set to FAILED and an ExecutionFailedError should be
    raised.
    If the execution succeeds, the object's Checkpoint should be set to
    SUCCEEDED.
    Once the Checkpoint is in the SUCCEEDED state, attempting to re-run the
    object should raise an AlreadyCompletedException.
    """

    class ExecutionFailedError(RuntimeError):
        """Thrown when the execute() method of this object fails.

        This exception should be raised by concrete child classes.
        """

    class AlreadySuccessfulException(Exception):
        """Thrown when execute() has previously succeeded and is reinvoked.

        This exception is thrown by the constructor of this class.
        Concrete child classes need not raise it, but should call the parent
        constructor.
        """

    @abstractmethod
    def __init__(self, name):
        # create a NOT_STARTED Checkpoint
        self.checkpoint = Checkpoint()

        # make sure name is a non-empty string
        if not isinstance(name, str):
            raise TypeError(f"Expected a {str}.")
        if not len(name) > 0:
            raise ValueError("Name cannot be empty.")
        self.name = name

    @abstractmethod
    def execute(self):
        """Asserts that no execution is allowed if it was successful before."""

        if self.checkpoint is CheckpointState.SUCCEEDED:
            raise self.AlreadySuccessfulException()


class Step(AbstractStep):
    """An installation step is an atomic executable process within a Stage."""

    def __init__(self, name, executable, *args, **kwargs):
        super().__init__(name)

        # make sure executable is a callable
        if not callable(executable):
            raise TypeError("Expected a callable.")
        # save args and kwargs for executable
        self.executable = executable
        self.executable_args = args
        self.executable_kwargs = kwargs

    def execute(self):
        """Attempts to execute this Step's callable and return its result."""

        super().execute()

        try:
            retval = self.executable(
                *self.executable_args,
                **self.executable_kwargs
            )
        except BaseException as exception:
            self.checkpoint.set_failed()
            raise self.ExecutionFailedError() from exception
        finally:
            # TODO maybe serialize checkpoint
            pass

        self.checkpoint.set_succeeded()
        return retval


class Stage(AbstractStep):
    """An installation Stage represents a set of individual steps."""

    class AmbiguousStepNameException(ValueError):
        """Raised when two Steps with the same name are added to a Stage."""

    def __init__(self, name, steps):
        super().__init__(name)

        # make sure name is a non-empty string
        if not isinstance(name, str):
            raise TypeError(f"Expected a {str}.")
        if not len(name) > 0:
            raise ValueError("Name cannot be empty.")
        self.name = name

        # make sure we got a list
        if not isinstance(steps, list):
            raise TypeError(f"Expected a {list}.")
        # create our steps dict
        self.steps = {}
        for step in steps:
            if not isinstance(step, Step):
                raise TypeError(f"Expected an object of type {Step}.")
            if step.name in self.steps:
                raise self.AmbiguousStepNameException(
                    f"Tried to add two or more Steps with the name "
                    f"'{step.name}' to this Stage."
                )
            self.steps[step.name] = step

    def execute(self):
        """Executes all Steps in this Stage which are not successful yet.

        Steps are executed sequentially.
        Steps whose Checkpoint is already marked as SUCCEEDED are not executed
        again.
        """

        super().execute()

        for step in self.steps.values():
            if step.checkpoint.state is not CheckpointState.SUCCEEDED:
                try:
                    step.execute()
                except BaseException as exception:
                    self.checkpoint.set_failed()
                    raise self.ExecutionFailedError() from exception

        self.checkpoint.set_succeeded()

    def get_checkpoint_states(self):
        """Returns a dict mapping each Step's name to its Checkpoint state."""

        checkpoint_states = dict()

        for name, step in self.steps.items():
            checkpoint_states[name] = step.checkpoint.state.name

        return checkpoint_states

    def set_checkpoint_states(self, input_dict):
        """Sets each Step's checkpoint state using the input dict.

        The input dict must contain each Step's name as a key and a
        CheckpointState-value as its respective value.
        """

        # make sure the input is a dict
        if not isinstance(input_dict, dict):
            raise TypeError(f"Expected a {dict}.")
        # make sure the entry count makes sense
        if len(input_dict) != len(self.steps):
            raise ValueError(
                f"Unexpected key count in checkpoint dict: "
                f"expected {len(self.steps)} but got {len(input_dict)}."
            )
        # make sure all keys and values are valid
        for step_name, checkpoint_state_name in input_dict.items():
            # make sure key is a string
            if not isinstance(step_name, str):
                raise TypeError(
                    f"Unexpected type in checkpoint dict: "
                    f"expected a {str}."
                )
            # make sure this Stage has a step by that name
            if not step_name in self.steps:
                raise ValueError(
                    f"Tried to set the checkpoint for a step which is not "
                    f"in this Stage: '{step_name}'."
                )
            # make sure value is a string
            if not isinstance(checkpoint_state_name, str):
                raise TypeError(
                    f"Unexpected type in checkpoint dict: "
                    f"expected a {str}."
                )
            # make sure value string is a valid CheckpointState-value
            try:
                CheckpointState[checkpoint_state_name]
            except KeyError as exception:
                raise ValueError(
                    f"Invalid checkpoint state in checkpoint dict: "
                    f"'{checkpoint_state_name}'."
                ) from exception

        # set each Step's checkpoint state using the input dict
        for step_name, checkpoint_state_name in input_dict.items():
            self.steps[step_name].checkpoint.state = CheckpointState[checkpoint_state_name]
