# Scripting untility functions that utilize 'fzf' for user interaction.
# Can be used directly but designed to be used in other fishscripts/functions.
# @dependencies: bat exa find

# A comprehensive function which lets the user select one or multiple files or directories.
function fzf_fileselect --description "Searches for files or directories using 'fzf' and prints the selected file- or directory-path(s)."
        # By default, search for a single file anywhere under the current directory. 
        # If '--directories' or '-d' is supplied as a parameter, search for directories instead
        # If '--multiple' or '-m' is supplied as a parameter, multiple files can be selected
        # If '--extended' or '-x' is supplied as a parameter, detailed file or directory information is displayed

        # base command flags
        set find_args -nowarn
        set exa_args --oneline --icons --color always
        set fzf_args --ansi

        ## commands running in fzf's preview window are each built using "prefix" + "flags" + "postfix"
        # directory preview
        set fzf_dir_preview_prefix 'exa'
        set fzf_dir_preview_flags '--icons --color always --all --group-directories-first'
        set fzf_dir_preview_postfix  '{-1}'
        # file preview
        set fzf_file_preview_prefix 'bat --color always {-1}'
        set fzf_file_preview_flags 'bat --color always {-1}'
        set fzf_file_preview_postfix 'bat --color always {-1}'

        # Check if the '--extended' or '-x' parameter was supplied
        if contains -- --extended $argv ; or contains -- -x $argv
                # show detailed directory information in the fzf preview window
                set fzf_dir_preview_flags --header --all --classify --long --group --git $fzf_dir_preview_flags
        end

        # build the fzf preview window commands
        set fzf_file_preview "$fzf_file_preview_prefix $fzf_file_preview_flags $fzf_file_preview_postfix"
        set fzf_dir_preview "$fzf_dir_preview_prefix $fzf_dir_preview_flags $fzf_dir_preview_postfix"

        # Check if the 'from-root' or '-r' parameter was supplied
        if contains -- --from-root $argv ; or contains -- -r $argv
                # search recursively under the system's root directory
                set search_starting_point /
        else
                # DEFAULT: search recursively under the current directory
                set search_starting_point .
        end

        # Check if the '--multiple' or '-m' parameter was supplied
        if contains -- --multiple $argv ; or contains -- -m $argv
                # enable multi-selection
                set fzf_args --multi $fzf_args
        end

        # Check if the '--directories' or '-d' parameter was supplied
        if contains -- --directories $argv ; or contains -- -d $argv
                # search for directories
                set find_args -type d $find_args
                set exa_args --list-dirs $exa_args
                set fzf_args --preview $fzf_dir_preview $fzf_args
        else
                # DEFAULT: search for files
                set find_args -type f $find_args
                set fzf_args --preview $fzf_file_preview $fzf_args
        end

        # use 'find' to search for files/directories under the selected directory
        find $search_starting_point $find_args 2>/dev/null \
        # handle whitespace in filename
        | sed 's/ /\\ /g' \
        # generate icons and colors using 'exa'
        | xargs exa $exa_args 2>/dev/null \
        # display the found files/directories in 'fzf'
        | fzf $fzf_args \
        # print only the last column (the path)
        | awk '{print $(NF)}'
end
