# Fish shell functions related to displaying and navigating the filesystem.
# DEPENDENCIES: exa

function ls --wraps exa --description "Lists files in the current (or specified) directory in a short listing."
        exa --group-directories-first $argv
end

function ll --wraps exa --description "Lists files in the current (or specified) directory in a detailed listing."
        exa --long --header --group --classify --git --icons --group-directories-first $argv
end

function la --wraps exa --description "Lists all (including hidden) files in the current (or specified) directory in a detailed listing."
        exa --long --header --group --classify --git --icons --group-directories-first --all $argv
end

function fcd --description "Uses 'fzf' to list and cd into directories under the current directory."
        cd (du . 2>/dev/null | awk '{print $2}' | sed 's/^\.\// /' | fzf --preview 'exa --oneline --classify --icons --all --group-directories-first {2}' | awk '{print $2}')
end

function fcda --description "Uses 'fzf' to list any accessible directories on the system and cd into them."
        cd (du / 2>/dev/null | awk '{print $2}' | sed 's/^/ /' | fzf --preview 'exa --oneline --classify --icons --all --group-directories-first {2}' | awk '{prin
t $2}')
end
