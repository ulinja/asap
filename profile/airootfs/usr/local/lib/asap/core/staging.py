"""This module defines the different stages and checkpoints of an installation.

The installation process is split into Stages, which themselves are split into
Steps. Both Stages and steps can be executed by calling their execute() method.
Depending on whether execution has been attempted previously, and depending on
its success, each Stage's and each Step's execution state is represented in the
form of a Checkpoint.
"""

from abc import ABC, abstractmethod
from enum import Enum, unique
import logging


@unique
class CheckpointState(Enum):
    """Represents the state of a checkpoint.

    Checkpoints can have three possible states:
    - NOT_STARTED: the execution associated with this checkpoint has not been
      attempted yet.
    - FAILED: the execution associated with this checkpoint has been attempted
      and did not succeed yet
    - SUCCEEDED: the execution associated with this checkpoint was successfully
      completed
    """

    NOT_STARTED = "not started"
    FAILED = "failed"
    SUCCEEDED = "succeeded"


class Checkpoint:
    """A Checkpoint represents the execution history of a Stage or Step.

    Parameters
    ----------
    state : CheckpointState, optional
        The state which this Checkpoint will have upon creation.

    Attributes
    ----------
    state : CheckpointState
        The execution state which this Checkpoint represents.
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
    """A abstract base class for Stage and Step.

    The objects represented by this class can be executed by invoking their
    execute() method.
    The success state of the most recent execution is saved in the form of a
    Checkpoint.
    If the execution of the object has never been attempted, its Checkpoint is
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

        Concrete child classes need not raise it directly, but must call
        super().execute().
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
        """Begins the execution of this Stage or Step."""

        if self.checkpoint is CheckpointState.SUCCEEDED:
            raise self.AlreadySuccessfulException()


class Step(AbstractStep):
    """A Step is an atomic installation step within a Stage.

    Steps take a callable, along with any number of arguments and keyword
    arguments for that callable, during construction.
    When a Step's execute() method is called, the args and kwargs supplied
    to the Step's constructor are passed to its callable, and the callable is
    executed. If any Exception is raised during the execution, the Step's
    checkpoint is set to the FAILED state, and the Step re-raises the Exception
    as an ExecutionFailedError. If no exception is raised, the Step's
    Checkpoint state is set to SUCCEEDED.

    Parameters
    ----------
    name : str
        The name of this Step.
    executable : callable
        The callable which will be executed when this Step is executed.
    *args : anything
        Any number of positional arguments which will be passed to executable.
    **kwargs : anything
        Any number of keyword arguments which will be passed to executable.

    Attributes
    ----------
    name : str
        The name of this Step.
    executable : callable
        The callable which will be executed when this Step is executed.
    executable_args : tuple
        The positional arguments which will be passed to executable.
    executable_kwargs : dict
        The keyword arguments which will be passed to executable.
    """

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
        """Attempts to execute this Step's callable and returns its result.

        Returns
        -------
        retval : anything
            Whatever this Step's callable returns.

        Raises
        ------
        AlreadySuccessfulException
            If execute() is called on a Step which has already succeeded.
        ExecutionFailedError
            If any kind of exception is raised during execution of this Step's
            callable.
        """

        super().execute()

        try:
            retval = self.executable(
                *self.executable_args,
                **self.executable_kwargs
            )
        except BaseException as exception:
            self.checkpoint.set_failed()
            raise self.ExecutionFailedError() from exception

        self.checkpoint.set_succeeded()
        return retval


class Stage(AbstractStep):
    """An installation Stage represents a sequence of individual Steps.

    When a Stage is executed, each Step of it is executed suqbsequently in the
    order in which they were supplied during the Stage's construction.
    Steps which are aleady marked as SUCCEEDED are skipped.
    If an ExecutionFailedError is raised during the execution of any Step,
    this Stage's Checkpoint is set to FAILED, and the ExecutionFailedError is
    re-raised.
    If all Steps were executed successfully, this Stage's Checkpoint is set to
    SUCCEEDED.

    Parameters
    ----------
    name : str
        The name of this Stage.
    steps : list of Steps
        The Steps which will be executed when the Stage is executed.
        The list of Steps cannot contain any Steps which share the same name.

    Attributes
    ----------
    name : str
        The name of this Stage.
    steps : dict
        A mapping containing Step's names as keys and the Step itself as
        the respective value.

    Raises
    ------
    AmbiguousStepNameException
        If two or more Steps in the list of steps share the same name.
    """

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

        Steps are executed in the order in which they were provided to this
        Stage's constructor.
        Steps whose Checkpoint is already marked as SUCCEEDED are not executed
        again.
        If any Step raises an ExecutionFailedException, the Stage's Checkpoint
        is set to the FAILED state, and the exception is re-raised.

        Raises
        ------
        AlreadySuccessfulException
            If execute() is called on a Stage which has already succeeded.
        ExecutionFailedError
            If any kind of exception is raised during execution of any of
            this Stage's Steps.

        Returns
        -------
        None
        """

        super().execute()

        for step in self.steps.values():
            if step.checkpoint.state is not CheckpointState.SUCCEEDED:
                try:
                    step.execute()
                except self.ExecutionFailedError as exception:
                    self.checkpoint.set_failed()
                    raise self.ExecutionFailedError() from exception

        self.checkpoint.set_succeeded()

    def get_checkpoint_states(self):
        """Returns a dict mapping each Step's name to its Checkpoint state.

        The returned dict represents the current execution state of each Step
        in this Stage.
        """

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
