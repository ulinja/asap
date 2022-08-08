### Custom bash aliases for interactive shell usage.
# DEPENDENCIES: exa git rsync trash-cli rmtrash

### general
# allow aliases to work with sudo as well
alias sudo='sudo '

## navigation
alias ls="exa --group-directories-first"
alias ll="exa --long --header --group --classify --git --icons --group-directories-first"
alias la="exa --long --header --group --classify --git --icons --group-directories-first --all"
alias ranger="ranger --choosedir=$HOME/.local/share/ranger/rangerdir ; cd $(cat $HOME/.local/share/ranger/rangerdir)"

## file deletion
#alias rm='rmtrash --forbid-root=ask-pass'
#alias rmdir='rmdirtrash --forbid-root=ask-pass'
alias tls="trash-list"
alias tem="trash-empty"
alias shred="shred --force --remove --zero --verbose"


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

## file renaming
alias rnmt="perl-rename --verbose --dry-run"
alias rnm="perl-rename --verbose"

## system power management
alias ssn="systemctl --no-wall poweroff"
alias srn="systemctl --no-wall reboot"
alias sus="systemctl suspend"
alias hib="systemctl hibernate"
