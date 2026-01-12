#!/usr/bin/env bash
#
# install.sh
#
##

set -o pipefail

BASE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly BASE_DIR

VIM_PLUGINS=(
    https://github.com/editorconfig/editorconfig-vim.git
    https://github.com/hashivim/vim-terraform.git
)

LN_OPTS=()

function _usage()
{
    cat << EOF
Usage: $0 [options]

Options:
    -f, --force  Overwrite existing files (default: false)
    -h, --help   Show this message
EOF
}

function install_dotfiles()
{
    local src_path

    echo "--> Installing dotfiles..."

    # Ignore current and upper directories
    GLOBIGNORE=".:.."

    for src_path in "${BASE_DIR}/src"/.* ; do
        ln -s -v "${LN_OPTS[@]}" "$src_path" "${HOME}"
    done
}

function install_vim_plugins()
{
    local plugin_repo
    local plugin_dir

    echo "--> Installing Vim plugins..."

    for plugin_repo in "${VIM_PLUGINS[@]}" ; do
        plugin_dir="${HOME}/.vim/pack/plugins/start/$( basename "${plugin_repo/.git/}" )"

        if [[ ! -d "$plugin_dir" ]] ; then
            echo "--> Installing plugin '$plugin_repo'"

            git clone "$plugin_repo" "$plugin_dir"
        else
            echo "--> Directory '$plugin_dir' already exists, running 'git pull'"

            git -C "$plugin_dir" pull
        fi
    done
}

function main()
{
    while [[ $# -gt 0 ]] ; do
        case $1 in
            -f|--force)
                LN_OPTS+=( --force )
            ;;
            -h|--help)
                _usage
                exit 0
            ;;
            *)
                echo "Invalid argument: $1"
                _usage
                exit 2
            ;;
        esac

        shift
    done

    install_dotfiles
    install_vim_plugins

    echo "--> Done"
}

main "$@"
