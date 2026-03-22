# Dotfiles

Personal development environment configuration managed with GNU Stow.

## Packages

- `fish`
- `ghostty`
- `tmux`
- `colima`
- `docker`
- `docker-compose`

## Bootstrap

```sh
./scripts/bootstrap.sh
exec fish -l
colima start
docker ps
```

## Remove links

```sh
stow -D -d "$HOME/Projects/dotfiles" -t "$HOME" ghostty fish tmux
```

## Notes

- `~/.config/fish/fish_variables` stays local and is not managed by this repo.
- This repo manages a host-minimum setup: shell, terminal, tmux, and container tooling. App runtimes such as Ruby, Node, and Rails should run inside project containers.
- `./scripts/bootstrap.sh` installs Homebrew packages from `Brewfile`, wires the Docker Compose plugin, applies `stow`, and tries to switch the default shell to `/opt/homebrew/bin/fish`.
- The bootstrap may prompt for `sudo` to add `fish` to `/etc/shells` before running `chsh`.
- `fish` loads the Homebrew environment from `~/.config/fish/conf.d/homebrew.fish`, so new formulas like `tmux` become available in new shells.
- After the first bootstrap, open a new terminal session or run `exec fish -l` to refresh the current shell before starting Colima.
- `colima` provides the container runtime on macOS. `docker` is the CLI, and `docker compose` remains available for multi-service projects.
- `ghostty` launches `fish` directly using `/opt/homebrew/bin/fish --login`.
- `tmux` expects `/opt/homebrew/bin/fish` and uses `pbcopy` for macOS clipboard integration.

## Tmux Shortcuts

- Prefix: `Ctrl-b`
- Split horizontal: `Ctrl-b` then `"` or `-`
- Split vertical: `Ctrl-b` then `%` or `|`
- New window: `Ctrl-b` then `c`
- Move between panes: `Ctrl-b` then `h`, `j`, `k`, or `l`
- Resize panes: `Ctrl-b` then `H`, `J`, `K`, or `L`
- Reload config: `Ctrl-b` then `r`
- Copy mode selection: `v`
- Copy selected text to macOS clipboard: `y` or `Enter`

## Container Workflow

```sh
docker run --rm -it ruby:3.3 irb
docker compose run --rm app bundle exec rails console
```
