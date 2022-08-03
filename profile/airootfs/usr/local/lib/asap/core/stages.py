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
    def __init__(self, name, checkpoint=None):
        if checkpoint is None:
            # create a NOT_STARTED Checkpoint
            self.checkpoint = Checkpoint()
        else:
            if not isinstance(checkpoint, Checkpoint):
                raise TypeError(f"Expected a {Checkpoint}.")
            self.checkpoint = checkpoint

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

    def __init__(self, name, executable, *args, checkpoint=None, **kwargs):
        super().__init__(name=name, checkpoint=checkpoint)

        # make sure executable is a callable
        if not callable(executable):
            raise TypeError("Expected a callable.")
        # save args and kwargs for executable
        self.executable = executable
        self.executable_args = args
        # delete parent class kwargs
        if 'checkpoint' in kwargs:
            del kwargs['checkpoint']
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

    def __init__(self, name, steps, checkpoint=None):
        super().__init__(name=name, checkpoint=checkpoint)

        # make sure name is a non-empty string
        if not isinstance(name, str):
            raise TypeError(f"Expected a {str}.")
        if not len(name) > 0:
            raise ValueError("Name cannot be empty.")
        self.name = name

        # make sure we got a list of Steps
        if not isinstance(steps, list):
            raise TypeError(f"Expected a {list}.")
        for step in steps:
            if not isinstance(step, Step):
                raise TypeError(f"Expected an object of type {Step}.")
        self.steps = steps

    def execute(self):
        """Executes all Steps in this Stage which are not successful yet.

        Steps are executed sequentially.
        Steps whose Checkpoint is already marked as SUCCEEDED are not executed
        again.
        """

        super().execute()

        for step in self.steps:
            if step.checkpoint.state is not CheckpointState.SUCCEEDED:
                try:
                    step.execute()
                except BaseException as exception:
                    self.checkpoint.set_failed()
                    raise self.ExecutionFailedError() from exception
                finally:
                    # TODO serialize Checkpoints
                    pass

        self.checkpoint.set_succeeded()
        # TODO serialize Checkpoints
