# Fish shell functions related to the 'rsync' utility

function cpr --wraps rsync --description "Copies files according to $argv using rsync. Does not overwrite existing files."
        rsync --update --recursive --archive --acls --xattrs --hard-links --protect-args --executability --verbose --progress --stats --itemize-changes --human-readable $argv
end

function mvr --wraps rsync --description "Moves files according to $argv using rsync. Deletes the source files upon completion. Will overwrite existing files."
        rsync --ignore-times --recursive --archive --acls --xattrs --hard-links --protect-args --executability --verbose --progress --stats --itemize-changes --human-readable --remove-source-files $argv
end

function cprf --wraps rsync --description "Copies files according to $argv using rsync. Will overwrite existing files."
        rsync --ignore-times --recursive --archive --acls --xattrs --hard-links --protect-args --executability --verbose --progress --stats --itemize-changes --human-readable $argv
end
