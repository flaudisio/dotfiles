# shellcheck shell=bash
# shellcheck source=/dev/null

# Must be in interactive mode
[[ -z "$PS1" ]] && return

# History
shopt -s histappend

HISTCONTROL=ignoredups:ignorespace
HISTSIZE=80000
HISTFILESIZE=160000
HISTTIMEFORMAT="[%d/%m/%y %T] "

# Color support
if command -v dircolors > /dev/null ; then
    eval "$( dircolors -b )"

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Prompt color
if [[ $( id -u ) -eq 0 ]] ; then
    PS1='\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\[\033[01;34m\]\w\[\033[00m\] \$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
esac

# Bash completion
if ! shopt -q -o posix ; then
    if [[ -f /usr/share/bash-completion/bash_completion ]] ; then
        . /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]] ; then
        . /etc/bash_completion
    fi

    if [[ -f ~/.bash_completion ]] ; then
        . ~/.bash_completion
    fi
fi

# Aliases
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# Additional files
for __rc_file in ~/.bashrc.d/*.bash ; do
    [[ -f "$__rc_file" ]] || continue
    . "$__rc_file"
done

unset __rc_file

# Golang
# export GOROOT="/opt/go"
# export PATH="${PATH}:${GOROOT}/bin"
export GOPATH="$HOME/go"
export PATH="${PATH}:${GOPATH}/bin"

# Tmux (must run last)

: "${ENABLE_TMUX:=""}"

if [[ -n "$ENABLE_TMUX" && $TERM != "screen" ]] ; then
    unset ENABLE_TMUX
    exec tmux
fi
