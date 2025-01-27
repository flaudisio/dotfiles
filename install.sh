#!/usr/bin/env bash
#
# install.sh
#
##

set -o pipefail

BaseDir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly BaseDir

VimPlugins=(
    https://github.com/editorconfig/editorconfig-vim.git
    https://github.com/hashivim/vim-terraform.git
)

LnOpts=()

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
    local src_file
    local src_dir

    echo "--> Installing dotfiles..."

    for src_file in "${BaseDir}/src"/.* ; do
        [[ -f "$src_file" ]] || continue

        ln -s -v "${LnOpts[@]}" "$src_file" "${HOME}"
    done

    echo "--> Creating .config symlinks..."

    for src_dir in "${BaseDir}/src/.config"/* ; do
        ln -s -v "${LnOpts[@]}" "$src_dir" "${HOME}/.config"
    done
}

function create_env_dirs()
{
    echo "--> Creating env directories..."

    mkdir -p -v "${HOME}/.bashrc.d" "${HOME}/.profile.d"
}

function install_vim_plugins()
{
    local plugin_repo
    local plugin_dir

    echo "--> Installing Vim plugins..."

    for plugin_repo in "${VimPlugins[@]}" ; do
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
                LnOpts+=( --force )
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
    create_env_dirs
    install_vim_plugins

    echo "--> Done"
}

main "$@"
