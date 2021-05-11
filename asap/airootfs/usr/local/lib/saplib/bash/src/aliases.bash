# Sapling default bash aliases for interactive shell usage.
# DEPENDENCIES: bat exa git rsync trash-cli

## navigation
alias ls="exa --group-directories-first"
alias ll="exa --long --header --group --classify --git --icons --group-directories-first"
alias la="exa --long --header --group --classify --git --icons --group-directories-first --all"

alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
alias ..5="cd ../../../../.."
alias ..6="cd ../../../../../.."

## replacements for gnu standard utils with newer versions
alias cat="bat --paging=never"
alias less="bat --paging=always"

# file deletion
alias del="rm --force --recursive --verbose -I"
alias shred="shred --force --remove --zero --verbose"

alias tls="trash-list"
alias tpt="trash-put"
alias tem="trash-empty"

## rsync
# don't overwrite newer files
alias cpr="rsync --update --recursive --archive --acls --xattrs --hard-links --protect-args --executability --verbose --progress --stats --itemize-changes --human-readable"
# force overwrite
alias cprf="rsync --ignore-times --recursive --archive --acls --xattrs --hard-links --protect-args --executability --verbose --progress --stats --itemize-changes --human-readable"
# delete source files
alias mvr="rsync --ignore-times --recursive --archive --acls --xattrs --hard-links --protect-args --executability --verbose --progress --stats --itemize-changes --human-readable --remove-source-files"

## git
alias ga="git add --verbose"
alias gaa="git add --verbose --all"
alias gc="git commit --verbose"
alias gst="git status"
alias gpsh="git push --verbose"
alias gpll="git pull --verbose"

# file renaming
alias rnmt="perl-rename --verbose --dry-run"
alias rnm="perl-rename --verbose"

# system power management
alias ssn="systemctl --no-wall poweroff"
alias srn="systemctl --no-wall reboot"
alias sus="systemctl suspend"
alias hib="systemctl hibernate"
