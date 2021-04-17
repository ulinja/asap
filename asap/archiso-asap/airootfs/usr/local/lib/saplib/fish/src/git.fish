# Fish shell functions relating to commonly used git commands

function ga --wraps 'git add' --description "Makes git track the specified files."
        git add --verbose $argv
end

function gaa --wraps 'git add' --description "Makes git track all unstaged changes in the repository (except for files specified in .gitignore)."
        git add --verbose --all
end

function gc --wraps 'git commit' --description "Commits the git repository in its current state, after opening $EDITOR and displaying changes since the last commit."
        git commit --verbose
end

function gst --wraps 'git status' --description "Displays the status of the current git repository."
        git status
end

function gpsh --wraps 'git push' --description "Pushes updates to the remote repository."
        git push --verbose
end

function gpll --wraps 'git pull' --description "Pulls updates from the remote repository."
        git pull --verbose
end
