# shellcheck shell=sh
# shellcheck source=/dev/null

# Includes user's private bin to PATH
export PATH="${HOME}/.local/bin:$PATH"

if [ -n "$BASH_VERSION" ] ; then
    if [ -f "${HOME}/.bashrc" ] ; then
        . "${HOME}/.bashrc"
    fi
fi

# Improve Qt integration with GTK. Requires 'qt5-style-plugins' package.
# Ref: https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications#QGtkStyle
export QT_QPA_PLATFORMTHEME="gtk2"

# Additional files
[ -n "$( ls -A ~/.profile.d/*.sh 2> /dev/null )" ] && . ~/.profile.d/*.sh
