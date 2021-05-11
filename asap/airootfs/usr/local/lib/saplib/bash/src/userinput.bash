# Functions for retrieving user input. Used in bash scripts.
# DEPENDENCIES: color

function prompt_yes_or_no () {
        # Prints all passed arguments prepended with '[INPUT] ' and appended
        # with ' [y/n] '. (The arguments should be a queestion)
        # Returns 0 if user typed 'y' or 'Y'.
        # Returns 3 if user typed 'n' or 'N'.
        # Returns 1 for everything else (invalid user input)

        printf "[INPUT] $@ [y/n] "
        read user_input

        if [[ $user_input =~ ^[yY]$ ]]; then
                return 0
        elif [[ $user_input =~ ^[nN]$ ]]; then
                return 3
        else
                return 1
        fi
}

function prompt_enter_to_continue () {
        # Prints the arguments and prompts the user to press enter to continue
        # on the same line.
        # Returns 0 on any input followed by a newline.

        printf "$@ "
        printf "Press [ENTER] to continue... "
        read foo
        unset foo
        return 0
}
