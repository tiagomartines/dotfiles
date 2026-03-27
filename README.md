# Dotfiles

Personal development environment configuration managed with GNU Stow.

## Packages

- `fish`
- `ghostty`
- `tmux`
- `neovim`
- `tree-sitter-cli`
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
stow -D -d "$HOME/Projects/dotfiles" -t "$HOME" ghostty fish tmux nvim macos
```

## Notes

- `~/.config/fish/fish_variables` stays local, is ignored by Stow, and is not managed by this repo.
- This repo manages a host-minimum setup: shell, terminal, tmux, and container tooling. App runtimes such as Ruby, Node, and Rails should run inside project containers.
- `./scripts/bootstrap.sh` installs Homebrew packages from `Brewfile`, wires the Docker Compose plugin, applies `stow`, and tries to switch the default shell to `/opt/homebrew/bin/fish`.
- The repo also manages a macOS `LaunchAgent` that keeps `Caps Lock` remapped to `Escape` across logins.
- The bootstrap also installs `neovim`, `ripgrep`, `fd`, and `fzf` for the editor workflow.
- The bootstrap also installs `tree-sitter-cli` for Neovim Treesitter parser compilation on the host.
- The bootstrap may prompt for `sudo` to add `fish` to `/etc/shells` before running `chsh`.
- `fish` loads the Homebrew environment from `~/.config/fish/conf.d/homebrew.fish`, so new formulas like `tmux` become available in new shells.
- After the first bootstrap, open a new terminal session or run `exec fish -l` to refresh the current shell before starting Colima.
- `colima` provides the container runtime on macOS. `docker` is the CLI, and `docker compose` remains available for multi-service projects.
- `ghostty` launches `fish` directly using `/opt/homebrew/bin/fish --login`.
- `tmux` expects `/opt/homebrew/bin/fish` and uses `pbcopy` for macOS clipboard integration.
- `vim` in `fish` opens `nvim`, and `EDITOR`/`VISUAL` are set to `nvim`.
- Neovim is intended to run on the host. Project runtimes and app CLIs should run in containers.

## macOS Keyboard

- `Caps Lock` is globally remapped to `Escape` with `hidutil`.
- Verify the active mapping with `hidutil property --get 'UserKeyMapping'`.
- Reset the current session temporarily with `hidutil property --set '{"UserKeyMapping":[]}'`.
- Disable the persistent remap with `launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.tmartines.capslock-escape.plist`.

## Tmux Shortcuts

- Prefix: `Ctrl-b`
- Split horizontal: `Ctrl-b` then `"` or `-`
- Split vertical: `Ctrl-b` then `%` or `|`
- New window: `Ctrl-b` then `c`
- Move between panes: `Ctrl-b` then `h`, `j`, `k`, or `l`
- Jump to pane by number: `Right Option+1..9`
- Resize panes: `Ctrl-b` then `H`, `J`, `K`, or `L`
- Reload config: `Ctrl-b` then `r`
- Copy mode selection: `v`
- Copy selected text to macOS clipboard: `y` or `Enter`

## Container Workflow

```sh
docker run --rm -it ruby:3.3 irb
docker compose run --rm app bundle exec rails console
```

- Keep the editor on the host and run project commands inside containers.
- Use devcontainers only when a specific project or team standard requires them.
- Running `vim` inside a container should be a fallback for debugging or ephemeral environments, not the default workflow.

## Neovim

Neovim is expected to run on the host, while app runtimes and project CLIs stay inside containers.

### Installation flow

- `./scripts/bootstrap.sh` installs the host binaries that the editor depends on: `neovim`, `ripgrep`, `fd`, `fzf`, and `tree-sitter-cli`.
- The first `nvim` launch bootstraps `lazy.nvim`, which then installs the configured plugins from `lua/plugins`.
- The same first launch also lets Mason install host-side language tooling declared in the config.
- Treesitter parsers install lazily the first time you open a supported filetype, one language at a time.

### Host tools installed by bootstrap

- `neovim`: the editor itself and the runtime that loads the Lua configuration shipped in this repo.
- `ripgrep`: fast text search backend used by picker workflows such as live grep.
- `fd`: fast file discovery backend used by file pickers.
- `fzf`: fuzzy matching engine used underneath `fzf-lua`.
- `tree-sitter-cli`: host-side parser compiler required for automatic Treesitter parser installation.

### Plugins installed on first Neovim launch

- `lazy.nvim`: plugin manager that bootstraps itself, loads the plugin specs, and keeps plugin installs reproducible with `lazy-lock.json`.
- `which-key.nvim`: keymap helper that shows leader-key groups and pending mappings as you type.
- `fzf-lua`: fuzzy finder UI for files, live grep, buffers, help tags, and opening a file directly in a new tab.
- `gitsigns.nvim`: Git integration that shows hunk markers in the sign column and exposes preview, blame, and hunk reset actions.
- `nvim-treesitter`: parser-based syntax highlighting and indentation with on-demand parser installation for supported languages.
- `mason.nvim`: package manager UI for external editor tooling such as language servers and formatters.
- `mason-lspconfig.nvim`: bridge between Mason packages and Neovim LSP setup, ensuring required language servers are installed.
- `mason-tool-installer.nvim`: startup helper that automatically installs non-LSP tools declared in the config.
- `nvim-lspconfig`: Neovim's LSP integration layer for diagnostics, keymaps, and server-specific configuration.
- `blink.cmp`: completion engine that provides insert-mode completion, command-line completion, and signature help.
- `conform.nvim`: formatter orchestrator used for format-on-save and manual formatting commands.

### Mason-managed language tooling

- `lua_ls`: Lua language server used for Neovim config and other Lua projects.
- `ts_ls`: TypeScript and JavaScript language server used for TS, TSX, JS, and related files.
- `stylua`: Lua formatter used by `conform.nvim`.
- `prettierd`: daemonized Prettier backend used by `conform.nvim` for JavaScript, TypeScript, JSON, Markdown, and YAML.
- Ruby and Rails language servers are intentionally not installed globally; manage them per project or inside containers.

### Treesitter parser coverage

- Supported parser languages: `bash`, `dockerfile`, `fish`, `git_config`, `gitcommit`, `gitignore`, `javascript`, `jsdoc`, `json`, `lua`, `markdown`, `markdown_inline`, `query`, `ruby`, `toml`, `tsx`, `typescript`, `vim`, `vimdoc`, and `yaml`.
- Treesitter is configured to enable parser-backed highlighting and indentation when a parser is available, then install missing parsers quietly for the supported languages above.
- If `tree-sitter-cli` is missing on the host, Neovim warns instead of attempting the parser install blindly.

### Key shortcuts

- Leader: `Space`
- `vim` in `fish` opens `nvim`
- Finder shortcuts:
  - `<leader>ff` files
  - `<leader>fg` live grep
  - `<leader>ft` files in a new tab
  - `<leader>fb` buffers
  - `<leader>fh` help tags
- Git shortcuts:
  - `]h` next hunk
  - `[h` previous hunk
  - `<leader>gp` preview hunk
  - `<leader>gb` toggle current-line blame
  - `<leader>gh` reset hunk
- LSP shortcuts:
  - `gd` definition
  - `gr` references
  - `gI` implementation
  - `K` hover
  - `<leader>ca` code action
  - `<leader>rn` rename
  - `<leader>cd` line diagnostics
  - `[d` previous diagnostic
  - `]d` next diagnostic
- Formatting shortcuts:
  - `<leader>cf` format
