# Fish shell functions replacing some standard gnu utils
# DEPENDENCIES: bat

function cat --wraps bat --description "Replacement of the 'cat' utility with the more modern 'bat'."
        bat --paging=never $argv
end

function less --wraps bat --description "Replacement of the 'less' utility with the more modern 'bat' in paging mode."
        bat --paging=always $argv
end
