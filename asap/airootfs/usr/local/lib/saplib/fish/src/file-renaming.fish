# Fish shell functions for bulk renaming of files
# DEPENDENCIES: perl-rename

function rnmt --wraps perl-rename --description "Performs a dry-run of 'perl-rename' on the specified arguments."
        perl-rename --verbose --dry-run $argv
end

function rnm --wraps perl-rename --description "Performs a 'perl-rename' on the specified arguments."
        perl-rename --verbose $argv
end
