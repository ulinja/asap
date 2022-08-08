"""Miscellaneous helper functions."""

from re import compile


def prompt_yes_or_no(question, ask_until_valid=False):
    """Prompts the user for an answer to the specified yes/no question.

    If 'ask_until_valid' is True, keeps repeating the prompt until the user
    provides recognizable input to answer the question.

    Parameters
    ----------
    question : str
        The question to ask the user while prompting. The string is prefixed
        with "[PROMPT  ]"suffixed
        with " (Yes/No) ".
    ask_until_valid : bool
        If this is set to True and the user provides an ambiguous answer, keeps
        prompting indefinitely until an unambiguous answer is read.

    Returns
    -------
    True : bool
        If the user has answered 'yes'.
    False : bool
        If the user has answered 'no'.
    None : None
        If 'ask_until_valid' is False and the user has provided an ambiguous
        response to the prompt.
    """

    user_input_is_valid = False

    regex_yes = compile(r"^(y)$|^(Y)$|^(YES)$|^(Yes)$|^(yes)$")
    regex_no = compile(r"^(n)$|^(N)$|^(NO)$|^(No)$|^(no)$")

    while(not user_input_is_valid):
        user_input = input(f"[PROMPT  ] {question} (Yes/No): ")

        if (regex_yes.match(user_input)):
            return True
        elif (regex_no.match(user_input)):
            return False
        elif (not ask_until_valid):
            return None
        else:
            print("[PROMPT  ] Unrecognized input.")
