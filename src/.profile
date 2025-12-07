# shellcheck shell=sh
# shellcheck source=/dev/null

# Includes user's private bin to PATH
export PATH="${HOME}/.local/bin:$PATH"

if [ -n "$BASH_VERSION" ] ; then
    if [ -f "${HOME}/.bashrc" ] ; then
        . "${HOME}/.bashrc"
    fi
fi

# Additional files
[ -n "$( ls -A ~/.profile.d/*.sh 2> /dev/null )" ] && . ~/.profile.d/*.sh
