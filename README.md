# dotfiles

My personal configuration files, symlinked into `$HOME` by a small installer script.

## Contents

- Shell: `.bashrc`, `.bash_aliases`, `.bashrc.d/`, `.profile`
- Tools: `.config/` (bat, ghostty, git, mise, uv, …), `.vimrc`, `.tmux.conf`, `.screenrc`
- CLI: `.gitconfig`, `.npmrc`, `.psqlrc`, `.terraformrc`, `.markdownlint.yml`

Everything under `src/` is the payload; the files in the repo root are tooling for the repo
itself and are not installed.

## Requirements

- `bash` and `git`
- `vim`, if you want the Vim plugins
- [mise](https://mise.jdx.dev), for the maintenance tasks below

## Installation

```bash
git clone https://github.com/flaudisio/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` walks `src/` and symlinks into `$HOME`:

- a file such as `src/.bashrc` becomes `$HOME/.bashrc`
- a directory such as `src/.config/` becomes `$HOME/.config/`, with each child symlinked
  into it

It also clones the Vim plugins listed in the script into `~/.vim/pack/plugins/start/`.

Existing files are not overwritten by default. Pass `--force` to replace them, or `--help`
for usage:

```bash
./install.sh --help
./install.sh --force
```

## Updating

```bash
cd ~/.dotfiles
git pull
./install.sh --force
```

## Maintenance

With [mise](https://mise.jdx.dev) installed, the repo exposes a few tasks:

| Task | Description |
| --- | --- |
| `mise run lint` | Run the prek hooks over all files |
| `mise run bump-version:patch` | Bump the version, commit, and tag |
| `mise run git-push` | Push the current branch and tags |

`bump-version:major`, `bump-version:minor`, and `bump-version:patch` are available.
Prek hooks (yamllint, shellcheck, whitespace) also run in CI on every pull request.

## License

[MIT](LICENSE).
