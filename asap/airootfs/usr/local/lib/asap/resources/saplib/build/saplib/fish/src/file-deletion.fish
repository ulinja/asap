# Fish shell functions relating to file removal.
# DEPENDENCIES: trash-cli

function del --wraps rm --description "Recursively and irrevocably deletes the specified directories, as well as any files inside them."
        rm --force --recursive --verbose -I $argv
end

function shred --wraps shred --description "Irrevocably overwrites the specified files with zeroes and removes them."
        # TODO add user confirmation
        shred --force --remove --zero --verbose $argv
end

function tls --wraps trash-list --description "Lists the files currently in the trash-bin."
        trash-list
end

function tpt --wraps trash-put --description "Places the specified files into the trash-bin (removes the files reversibly)."
        trash-put $argv
end

function tem --wraps trash-empty --description "Irreversibly removes all files currently in the trash-bin."
        # TODO add user confirmation
        trash-empty
end
