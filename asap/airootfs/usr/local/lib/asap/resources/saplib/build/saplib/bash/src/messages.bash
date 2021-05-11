# User messages printed to Standard output. Used in bash scripts.
# DEPENDENCIES: color


function success_message () {
        # prints the arguments as a success message
        echo -e "$(color bold black green)[SUCCESS]$(color) $@"
}

function warning_message () {
        # prints the arguments as a warning message
        echo -e "$(color bold black yellow)[WARNING]$(color) $@"
}

function critical_warning_message () {
        # prints the arguments as a critical warning message
        echo -e "$(color bold underline blink black yellow)[WARNING]$(color) $@"
}

function error_message () {
        # prints the arguments as an error message. used for user-side errors
        echo -e "$(color bold black red)[ERROR]$(color) $@"
}

function exception_message () {
        # prints the arguments as an exception message. used for programmer-side errors
	echo -e "$(color bold white red)[EXCEPTION]$(color) $@"
}

function info_message () {
        # prints the arguments as an info message
	echo -e "$(color black white)[INFO]$(color) $@"
}

function debug_message () {
        # prints the arguments as a debug message if $DEBUGMESSAGES = true
        if [ "$SAPLIB_DEBUGMESSAGES" = true ]; then
                echo -e "$(color blue white)[DEBUG]$(color) $@"
        fi
}
