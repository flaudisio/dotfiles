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

# Dev
alias tig='tig --all'
alias svim='EDITOR=vim sudoedit -H'

command -v colordiff > /dev/null &&
    alias diff='colordiff'

# ------------------------------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------------------------------

function __msg()
{
    echo "$@" >&2
}

# Mise
function load_mise()
{
    command -v mise > /dev/null || return 0

    # Ref: https://mise.jdx.dev/getting-started.html#bash
    eval "$( mise activate bash )"
}

load_mise

# ASDF
function load_asdf()
{
    [[ ! -d "$HOME/.asdf" ]] && return

    . "${HOME}/.asdf/asdf.sh"
    . "${HOME}/.asdf/completions/asdf.bash"
}

load_asdf

function update_asdf_plugin()
{
    local set_global_version=1
    local plugin
    local latest_version

    if [[ -z "$1" ]] ; then
        __msg "Usage: ${FUNCNAME[0]} [--no-global-version] <plugin1> [plugin2] [pluginN]"
        return 2
    fi

    if [[ "$1" == "--no-global-version" ]] ; then
        set_global_version=0
        shift
    fi

    for plugin in "$@" ; do
        echo "--> Updating $plugin"

        latest_version="$( asdf latest "$plugin" )"

        if [[ -z "$latest_version" ]] ; then
            __msg "Error: no latest version found"
            return 1
        fi

        echo "Installing $plugin $latest_version"

        asdf install "$plugin" "$latest_version"

        if [[ $set_global_version -eq 1 ]] ; then
            echo "Setting global version to $latest_version"

            asdf global "$plugin" "$latest_version"
        fi
    done
}

function install_tool_versions()
{
    local tools_file=".tool-versions"
    local tool
    local version
    local versions

    if ! command -v asdf > /dev/null ; then
        __msg "Error: 'asdf' command not found"
        return 1
    fi

    if [[ ! -f "$tools_file" ]] ; then
        __msg "Tools file '$tools_file' not found; ignoring"
        return 0
    fi

    __msg "Adding plugins"

    grep -v '^#' "$tools_file" | cut -d ' ' -f 1 | xargs -I '{}' asdf plugin-add '{}'

    grep -E -v '^(#.*)*$' "$tools_file" \
        | \
        while read -r tool versions ; do
            [[ -z "$tool" ]] && continue

            for version in $versions ; do
                [[ "$version" == "system" ]] && continue

                __msg "Installing $tool $version"

                asdf install "$tool" "$version"
            done
        done
}

if command -v bat > /dev/null ; then
    # Overwrite colordiff
    unalias diff 2> /dev/null

    function diff()
    {
        command diff "$@" | bat -l diff -p
    }

    # Aliases
    alias dbat='bat -l diff'
    alias jbat='bat -l json'
    alias ybat='bat -l yaml'
    alias hbat='bat -l hcl'
    alias shbat='bat -l sh -p'

    # Ref: https://github.com/sharkdp/bat#using-a-different-pager
    export BAT_PAGER='less -R -F'

    # Ref: https://github.com/sharkdp/bat#man
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
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
    mkdir -pv "$@" || return
    cd "$@"
}

function cpmk()
{
    if [[ $# -lt 2 ]] ; then
        echo "Usage: ${FUNCNAME[0]} SOURCE... DIRECTORY"
        echo
        echo "Examples:"
        echo "  ${FUNCNAME[0]} file1 /some/folder"
        echo "  ${FUNCNAME[0]} file1 file2 /another/example/folder"
        return 2
    fi

    # Get the last argument
    local -r dest="${*: -1}"

    mkdir -pv "$dest" || return
    cp -vi "$@"
}

function grt()
{
    local repo_root

    if ! repo_root="$( git rev-parse --show-toplevel )" ; then
        return 1
    fi

    [[ "$PWD" != "$repo_root" ]] && cd "$repo_root"
}

function xc()
{
    cat "$@" | xclip -rmlastnl -selection clipboard &> /dev/null
}

# aws-vault exec
function ax()
{
    local profile

    if [[ "$1" == "ls" ]] ; then
        echo "+ aws-vault list"
        aws-vault list
        return 0
    fi

    if [[ $# -lt 2 ]] ; then
        echo "Usage:"
        echo "  ax ls"
        echo "  ax <profile> <command> [args]"
        return 2
    fi

    profile="$1"
    shift

    echo "+ aws-vault exec $profile -- $*"
    aws-vault exec "$profile" -- "$@"
}

# Create empty executable file
function cx()
{
    local -r file="$1"

    if [[ -z "$file" ]] ; then
        __msg "Usage: ${FUNCNAME[0]} /path/to/file.sh"
        return 2
    fi

    (
        set -ex
        mkdir -p "$( dirname "$file" )"
        touch "$file"
        chmod 755 "$file"
    )
}

# Fix permissions: directories = 755, files = 644
function fixperms()
{
    local opts=()

    if [[ "$1" == "-v" ]] ; then
        opts+=( -v )
        shift
    fi

    local -r target_dir="$1"

    if [[ -z "$target_dir" ]] ; then
        __msg "Usage: ${FUNCNAME[0]} [-v] DIRECTORY"
        return 2
    fi

    echo "Updating directory permissions of '$target_dir' to 755 (rwxr-xr-x) ..."
    find "$target_dir" -type d -exec chmod "${opts[@]}" 755 {} \;

    [[ "${opts[0]}" == "-v" ]] && echo

    echo "Updating file permissions of '$target_dir' to 644 (rw-r--r--) ..."
    find "$target_dir" -type f -exec chmod "${opts[@]}" 644 {} \;
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

function makevenv()
{
    local -r venv_name="$1"
    local -r venv_dir="${HOME}/.venvs/${venv_name}"

    if [[ -z "$venv_name" ]] ; then
        __msg "Usage: ${FUNCNAME[0]} <virtualenv>"
        return 2
    fi

    __msg "Creating virtualenv on '$venv_dir'"

    if python3 -m venv --upgrade-deps "$venv_dir" ; then
        __msg "Success! Activating it now"

        . "${venv_dir}/bin/activate"
        return
    fi

    __msg "Error creating virtualenv; see output for details"
    return 1
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

    echo "$ifconfig_ret" | xclip -filter -selection clipboard || return

    echo "$ifconfig_ret copied to clipboard!"
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
    echo '¯\_(ツ)_/¯' | xclip -rmlastnl -selection clipboard &> /dev/null
}
