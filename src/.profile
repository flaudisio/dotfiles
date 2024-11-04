# shellcheck shell=sh
# shellcheck source=/dev/null

if [ -n "$BASH_VERSION" ] ; then
    if [ -f "${HOME}/.bashrc" ] ; then
        . "${HOME}/.bashrc"
    fi
fi

# Default PATH
if [ "$( id -u )" = "0" ] ; then
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
else
    PATH="${HOME}/.local/bin:/snap/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
fi

# Includes user's private bin to PATH if it exists
if [ -d "${HOME}/bin" ] ; then
    PATH="${HOME}/bin:$PATH"
fi

# Additional files
[ -n "$( ls -A ~/.profile.d/*.sh 2> /dev/null )" ] && . ~/.profile.d/*.sh
