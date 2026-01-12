# shellcheck shell=bash
# shellcheck source=/dev/null

# ------------------------------------------------------------------------------
# ALIASES
# ------------------------------------------------------------------------------

# Core
alias -- -='cd -'
alias l='ls -lh'
alias sl='ls -lh'
alias lsl='ls -lh'
alias lsa='ls -lhA'
alias pathcount="awk -F '/' '{ print NF-1 }'"

# shellcheck disable=SC2032
alias rm='rm -I'

# SSH / SCP / rsync
alias scpi='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR'
alias sshi='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR'
alias rsynci='rsync -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR"'

# Misc
alias delpyc='find . -depth -name "__pycache__" -exec rm -rf {} \;'
alias eo='exo-open'
alias tree-no-git='tree --dirsfirst -F -a -I ".git|.terragrunt-cache|.terraform|.venv|__pycache__"'

# Infra
alias k='kubectl'

# Dev
alias tig='tig --all'
alias svim='sudo -H vim'

# ------------------------------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------------------------------

function __msg()
{
    echo "$*" >&2
}

if command -v bat > /dev/null ; then
    function diff()
    {
        command diff "$@" | bat -l diff -p
    }

    # Aliases
    alias dbat='bat -l diff'
    alias hbat='bat -l hcl'
    alias jbat='bat -l json'
    alias ybat='bat -l yaml'
    alias shbat='bat -l sh -p'
    alias tbat='bat -l toml'

    # Ref: https://github.com/sharkdp/bat#using-less-as-a-pager
    export BAT_PAGER='less'

    # Ref: https://github.com/sharkdp/bat/issues/2753#issuecomment-1793724885
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT='-c'
fi

function ..()
{
    local hops="${1:-1}"
    local dest=""

    if [[ ! $hops =~ ^[0-9]+$ ]] ; then
        __msg "Usage: .. HOPS"
        return 2
    fi

    while [[ $hops -gt 0 ]] ; do
        dest="${dest}../"
        (( hops-- ))
    done

    cd "$dest"
}

function mkcd()
{
    mkdir -p -v "$@" || return
    cd "$@"
}

function cpmk()
{
    if [[ $# -lt 2 ]] ; then
        __msg "Usage: ${FUNCNAME[0]} SOURCE... DIRECTORY"
        __msg
        __msg "Examples:"
        __msg "  ${FUNCNAME[0]} file1 /some/folder"
        __msg "  ${FUNCNAME[0]} file1 file2 /another/example/folder"
        return 2
    fi

    # Get the last argument
    local -r dest="${*: -1}"

    mkdir -p -v "$dest" || return
    cp -vi "$@"
}

# shellcheck disable=SC2120
function xc()
{
    if [[ -n "$1" ]] ; then
        cat "$@" | xclip -rmlastnl -selection clipboard
    else
        xclip -rmlastnl -selection clipboard
    fi
}

function grt()
{
    local repo_root

    if ! repo_root="$( git rev-parse --show-toplevel )" ; then
        return 1
    fi

    [[ "$PWD" != "$repo_root" ]] && cd "$repo_root"
}

# Create empty file, ensuring all parent directories exist
function cf()
{
    local -r file="$1"
    local -r mode="${2:-"664"}"

    if [[ -z "$file" ]] ; then
        __msg "Usage: ${FUNCNAME[0]} /path/to/file"
        return 2
    fi

    (
        set -ex
        mkdir -p "$( dirname "$file" )"
        touch "$file"
        chmod "$mode" "$file"
    )
}

# Create an empty executable file
function cx()
{
    local -r file="$1"

    if [[ -z "$file" ]] ; then
        __msg "Usage: ${FUNCNAME[0]} /path/to/file.sh"
        return 2
    fi

    cf "$file" 755
}

function debchangelog()
{
    if [[ -z "$1" ]] ; then
        __msg "Usage: ${FUNCNAME[0]} <package>"
        return 2
    fi

    zless "/usr/share/doc/$1"/changelog*.gz
}

# shellcheck disable=SC2033
function fcleanup()
{
    case $1 in
        --tf|--terraform)
            find . -type d \( -name '.terragrunt-cache' -o -name '.terraform' \) -print -prune -exec rm -rf '{}' \;
            find . -type f -name '.terraform.lock.hcl' -print -prune -exec rm -f '{}' \;
        ;;
        *)
            __msg "Usage: ${FUNCNAME[0]} --tf|--terraform"
            return 2
        ;;
    esac
}

function genmac()
{
    # The last sed expression ensures the unicast/multicast bit is set to zero
    # Ref:
    # - https://serverfault.com/a/801504
    # - https://stackoverflow.com/a/42683473
    openssl rand -hex 6 | sed -E -e 's|(..)|\1:|g' -e 's|:$||' -e 's|^(.)[13579bdf]|\10|'
}

function myip()
{
    local ifconfig_ret

    ifconfig_ret="$( curl --fail -sSL "$@" https://ifconfig.me 2>&1 )"

    if [[ "$ifconfig_ret" == *error* ]] ; then
        __msg "Fatal: $ifconfig_ret"
        return 1
    fi

    echo "$ifconfig_ret" | xc || return

    __msg "$ifconfig_ret copied to clipboard!"
}

function tp()
{
    case $1 in
        on|1)
            synclient TouchpadOff=0
        ;;
        off|0)
            synclient TouchpadOff=1
        ;;
        *)
            __msg "Usage: ${FUNCNAME[0]} <1|0>"
            return 2
        ;;
    esac
}

function shrug()
{
    echo '¯\_(ツ)_/¯' | xc
}
