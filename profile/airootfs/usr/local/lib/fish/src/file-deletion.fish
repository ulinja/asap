# Fish shell functions relating to file removal.
# DEPENDENCIES: trash-cli rmtrash

function rm --wraps rmtrash --description "Removes files"
        rmtrash --forbid-root=ask-pass $argv
end

function rmdir --wraps rmdirtrash --description "Removes directories"
        rmdirtrash --forbid-root=ask-pass $argv
end

function shrz --wraps shred --description "Irrevocably overwrites the specified files with zeroes and removes them."
        # TODO add user confirmation
        shred --force --remove --zero --verbose $argv
end

function tls --wraps trash-list --description "Lists the files currently in the trash-bin."
        trash-list
end

function tem --wraps trash-empty --description "Irreversibly removes all files currently in the trash-bin."
        # TODO add user confirmation
        trash-empty
end
