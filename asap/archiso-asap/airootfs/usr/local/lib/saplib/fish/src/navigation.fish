# Fish shell functions related to displaying and navigating the filesystem.
# @dependencies: exa

function ls --wraps exa --description "Lists files in the current (or specified) directory in a short listing."
        exa --group-directories-first $argv
end

function ll --wraps exa --description "Lists files in the current (or specified) directory in a detailed listing."
        exa --long --header --group --classify --git --icons --group-directories-first $argv
end

function la --wraps exa --description "Lists all (including hidden) files in the current (or specified) directory in a detailed listing."
        exa --long --header --group --classify --git --icons --group-directories-first --all $argv
end

function fcd --description "Search for and change into a directory somwhere under the current working directory."
        set fzf_fileselect_flags --directories

        set target_dir (fzf_fileselect $fzf_fileselect_flags)
        # check if $target_dir is empty
        if string length -q -- $target_dir
                cd $target_dir
        end
end

function frcd --description "Search for and change into a directory anywhere on the system."
        set fzf_fileselect_flags --directories --from-root

        set target_dir (fzf_fileselect $fzf_fileselect_flags)
        # check if $target_dir is empty
        if string length -q -- $target_dir
                cd $target_dir
        end
end
