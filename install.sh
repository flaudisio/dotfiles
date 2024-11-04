#!/usr/bin/env bash
#
# install.sh
#
##

set -o pipefail

BaseDir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly BaseDir

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

function install_pathogen()
{
    if ! command -v wget &> /dev/null ; then
        echo "--> wget not found, so pathogen.vim will not be installed" >&2
    fi

    echo "--> Installing pathogen.vim..."

    mkdir -p -v "${HOME}/.vim/{autoload,bundle}"

    wget -q https://tpo.pe/pathogen.vim -O "${HOME}/.vim/autoload/pathogen.vim"
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
    install_pathogen

    echo "--> Done"
}

main "$@"
