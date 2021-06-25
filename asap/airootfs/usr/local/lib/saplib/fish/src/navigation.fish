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

function cdn --description "Search for and change into a directory somwhere under the current working directory."
        set fzf_fileselect_flags --directories

        set target_dir (fzf_fileselect $fzf_fileselect_flags)
        # check if $target_dir is empty
        if string length -q -- $target_dir
                cd $target_dir
        end
end

function cdf --description "Find and change into a directory anywhere on the system."
        set fzf_fileselect_flags --directories --from-root

        set target_dir (fzf_fileselect $fzf_fileselect_flags)
        # check if $target_dir is empty
        if string length -q -- $target_dir
                cd $target_dir
        end
end

function cdb --description "Move backwards in the directory tree along the current path."
    # generate a list of all ancestors of the absolute path from root to the current working directory
    # (if the working directory is '/foo/bar/baz': the list contains '/foo/bar', '/foo' and '/')
    set dirs (dirname (pwd))
    while [ $dirs[-1] != '/' ]
        set dirs $dirs (dirname $dirs[-1])
    end

    # open 'fzf' and cd into the directory chosen from the list
    set target_dir (printf '%s\n' $dirs | xargs exa --oneline --icons --color always --list-dirs | fzf --ansi --preview 'exa --icons --color always --all --group-directories-first --classify {-1}' | awk '{print $(NF)}')
    if string length -q -- $target_dir
            cd $target_dir
    end
end

function ranger --wraps ranger --description "Exit ranger into the last opened directory."
    /usr/bin/ranger --choosedir=$HOME/.local/share/ranger/rangerdir
    set LASTDIR (cat $HOME/.local/share/ranger/rangerdir)
    cd $LASTDIR
end
