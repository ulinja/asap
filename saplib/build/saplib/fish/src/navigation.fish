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
