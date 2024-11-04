#!/usr/bin/env bash
#
# install.sh
#

set -o pipefail

BaseDir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly BaseDir

CreateEnvDirs=0
InstallGitConfig=0
InstallPathogen=0
LnOpts=()

function _usage()
{
    cat << EOF
Usage: $0 [options]

Options:
    -f, --force      Overwrite existing files.
    -g, --gitconfig  Install .gitconfig.
    -d, --env-dirs   Create the ~/.bashrc.d and ~/.profile.d directories.
    -p, --pathogen   Install pathogen.vim.
    -h, --help       Show this message.
EOF
}

function install_dotfiles()
{
    local dotfile
    local filename

    echo "--> Installing dotfiles..."

    for dotfile in "${BaseDir}/dotfiles"/* ; do
        filename="$( basename "$dotfile" )"

        if [[ $InstallGitConfig -eq 0 && "$filename" == "gitconfig" ]] ; then
            continue
        fi

        ln -s -v "${LnOpts[@]}" "$dotfile" "${HOME}/.$filename"
    done
}

function create_dotconfig_links()
{
    local src_dir

    echo "--> Creating .config symlinks..."

    for src_dir in "${BaseDir}/dotconfig"/* ; do
        ln -s -v "${LnOpts[@]}" "$src_dir" "${HOME}/.config"
    done
}

function create_env_dirs()
{
    if [[ $CreateEnvDirs -eq 0 ]] ; then
        echo "--> Skipping creation of env directories"
        return
    fi

    echo "--> Creating additional directories..."

    mkdir -p -v "${HOME}/.bashrc.d" "${HOME}/.profile.d"
}

function install_pathogen()
{
    if [[ $InstallPathogen -eq 0 ]] ; then
        echo "--> Skipping pathogen.vim installation"
        return
    fi

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
            -g|--gitconfig)
                InstallGitConfig=1
            ;;
            -d|--env-dirs)
                CreateEnvDirs=1
            ;;
            -p|--pathogen)
                InstallPathogen=1
            ;;
            -h|--help)
                _usage
                exit 0
            ;;
            *)
                echo -e "Invalid argument: $1"
                _usage
                exit 2
            ;;
        esac

        shift
    done

    install_dotfiles
    create_dotconfig_links
    create_env_dirs
    install_pathogen

    echo "--> Done"
}

main "$@"
