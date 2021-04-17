#!/bin/bash

# A library of functions used in asap scripts.
# Functions which should support interactive use do not belong in here, they
# should be placed into '/usr/local/bin' as executable scripts instead.

source "$SAPLIB_BASH"
source "$ASAP_CONFIG"

function run_if_no_checkpoint () {
        # Tries to run the specified script.
        # If the script's basename is already present in the checkpoint-file, execution is skipped.
        # Returns:
        #       0 if the script was executed and ran sucessfully
        #       1 if the script was executed but returned a non-zero exit code
        #       3 if a checkpoint exists and script execution was skipped
        #       4 if the passed number of arguments is invalid or the specified script was not found

        # argument sanity check: exactly one argument
        if [ "$#" -ne 1 ]; then
                exception_message "Number of arguments supplied to $0 must be 1"
                return 4
        fi

        local target_script="$1"
        # argument validity check: the supplied script exists
        if [ ! -x "$target_script" ]; then
                exception_message "Script $target_script does not exist or is not executable"
                return 4
        fi

        # Check if script is already listed in the checkpoint file.
        # If so, skip execution. Else, run it.
        grep "$(basename $target_script)" "$ASAP_CHECKPOINTFILE" 1>/dev/null 2>/dev/null
        if [ "$?" -eq 0 ]; then
                debug_message "Checkpoint exists: skipping script $(basename $target_script)"
                return 3
        else
                # add an extra prompt before execution of each script for debug mode
                if [ "$ASAP_DEBUGMODE" = true ]; then
                        prompt_enter_to_continue "About to run $(basename $target_script)."
                fi
                # execute the script
                debug_message "Running $(basename $target_script)"
                /bin/bash "$target_script"
                if [ "$?" -eq 0 ]; then
                        return 0
                else
                        return 1
                fi
        fi
}

function check_previous_stages_completion () {
        # Checks the checkpointfile on whether the previous stages have been completed.
        # Returns 0 if all previous stages were completed.
        # Returns 1 and prints a warning message if some previous stages are missing from the checkpointfile.


        # argument sanity check: number of arguments should be exactly 1
        if [ "$#" -ne 1 ]; then
                exception_message "Number of arguments supplied to $0 must be 1"
                return 1
        fi
        # argument sanity check: should be an integer
        if [[ ! $1 =~ ^[0-9]+$ ]]; then
                exception_message "Unexpected format for argument '$1': expected a non-negative integer."
                return 1
        fi

        local stage_num="$1"
        # handle edge case: stage 0 has no prerequisites
        if [ "$stage_num" = 0 ]; then
                return 0
        fi
        local largest_previous_stage_num=$(( $stage_num - 1))
        local previous_stage_nums=($(seq 0 $largest_previous_stage_num))

        # go through checkpointfile and check whether previous stage checkpoints were set
        local some_stage_is_missing=false
        for i in "${previous_stage_nums[@]}"; do
                local stage_name="stage$i"
                grep "$stage_name" "$ASAP_CHECKPOINTFILE" 1>/dev/null 2>/dev/null
                if [ "$?" -ne 0 ]; then
                        warning_message "Stage $i was not completed."
                        local some_stage_is_missing=true
                fi
        done

        if [ "$some_stage_is_missing" = true ]; then
                return 1
        fi
        return 0
}

function run_stage () {
        # Runs all setup scripts in a stage.
        # Ensures that the checkpoints from previous stages are present.
        # Sets a checkpoint for each script that ran successfully.
        # Sets a checkpoint for the stage itself if every script in it ran successfully.

        # argument sanity check: number of arguments should be exactly 1
        if [ "$#" -ne 1 ]; then
                exception_message "Number of arguments supplied to $0 must be 1"
                return 1
        fi
        # argument sanity check: should be an integer
        if [[ ! $1 =~ ^[0-9]+$ ]]; then
                exception_message "Unexpected format for argument '$1': expected a non-negative integer."
                return 1
        fi

        local stage_num=$1
        local stage_name="stage$stage_num"
        local script_dir="$ASAP_SCRIPTS_DIR/$stage_name"

        # Check whether preceeding stages were completed
        check_previous_stages_completion "$stage_num"
        if [ "$?" -ne 0 ]; then
                error_message "Not all previous stages were completed successfully!"
                warning_message "Aborting..."
                return 1
        fi

        # Check if this stage was completed already
        grep "$stage_name" "$ASAP_CHECKPOINTFILE" 1>/dev/null 2>/dev/null
        if [ "$?" -eq 0 ]; then
                error_message "Stage $stage_num was already completed!"
                warning_message "Aborting..."
                return 1
        fi

        info_message "Starting Stage $stage_num..."

        # run every script for this stage
        for script in "$script_dir"/*.sh; do
                scriptname="$(basename $script)"
                run_if_no_checkpoint "$script" ; exit_status="$?"
                if [ "$exit_status" -eq 0 ]; then
                        asap_set-checkpoint "$scriptname"
                elif [ "$exit_status" -eq 1 ]; then
                        exception_message "Failed to run $(realpath $script) without errors!"
                        info_message "Please resolve the errors and run stage $stage_num again to resume where you left off."
                        return "$exit_status"
                fi
                unset exit_status
        done

        # log stage completion to checkpointfile
        success_message "Stage $stage_num completed."
        asap_set-checkpoint "$stage_name"
}
