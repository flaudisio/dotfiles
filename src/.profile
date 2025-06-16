# shellcheck shell=sh
# shellcheck source=/dev/null

# Includes user's private bin to PATH if it exists
if [ -d "${HOME}/bin" ] ; then
    PATH="${HOME}/bin:$PATH"
fi

if [ -d "${HOME}/.local/bin" ] ; then
    PATH="${HOME}/.local/bin:$PATH"
fi

if [ -n "$BASH_VERSION" ] ; then
    if [ -f "${HOME}/.bashrc" ] ; then
        . "${HOME}/.bashrc"
    fi
fi

# Additional files
[ -n "$( ls -A ~/.profile.d/*.sh 2> /dev/null )" ] && . ~/.profile.d/*.sh
