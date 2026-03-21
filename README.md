# Dotfiles

Personal development environment configuration managed with GNU Stow.

## Packages

- `fish`
- `ghostty`

## Bootstrap

```sh
brew install stow
stow --restow -d "$HOME/Projects/dotfiles" -t "$HOME" ghostty fish
```

## Remove links

```sh
stow -D -d "$HOME/Projects/dotfiles" -t "$HOME" ghostty fish
```

## Notes

- `~/.config/fish/fish_variables` stays local and is not managed by this repo.
- `ghostty` launches `fish` directly using `/opt/homebrew/bin/fish --login`.
