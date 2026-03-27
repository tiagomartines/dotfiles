#!/usr/bin/env bash

set -euo pipefail

log() {
  printf '==> %s\n' "$*"
}

warn() {
  printf 'Warning: %s\n' "$*" >&2
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

brew_healthy() {
  local brew_bin="$1"

  [[ -x "$brew_bin" ]] || return 1
  "$brew_bin" config >/dev/null 2>&1 || return 1
  "$brew_bin" bundle --help >/dev/null 2>&1 || return 1
}

find_brew() {
  local preferred_brew="/opt/homebrew/bin/brew"

  if brew_healthy "$preferred_brew"; then
    printf '%s\n' "$preferred_brew"
    return 0
  fi

  return 1
}

install_homebrew() {
  command -v curl >/dev/null 2>&1 || die "curl is required to install Homebrew."

  log "Installing Homebrew to /opt/homebrew"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

current_login_shell() {
  local current_user=""
  local user_shell=""

  current_user="$(id -un)"

  if command -v dscl >/dev/null 2>&1; then
    user_shell="$(dscl . -read "/Users/$current_user" UserShell 2>/dev/null | awk '{print $2}')"
  fi

  if [[ -z "$user_shell" ]]; then
    user_shell="${SHELL:-}"
  fi

  printf '%s\n' "$user_shell"
}

caps_lock_escape_mapping_json() {
  printf '%s\n' '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771113}]}'
}

ensure_shell_registered() {
  local fish_bin="$1"

  if grep -qxF "$fish_bin" /etc/shells; then
    return 0
  fi

  log "Registering $fish_bin in /etc/shells (sudo required)"
  printf '%s\n' "$fish_bin" | sudo tee -a /etc/shells >/dev/null

  grep -qxF "$fish_bin" /etc/shells || die "Could not add $fish_bin to /etc/shells."
}

ensure_default_shell() {
  local fish_bin="$1"
  local current_user=""
  local user_shell=""

  current_user="$(id -un)"
  user_shell="$(current_login_shell)"

  if [[ "$user_shell" == "$fish_bin" ]]; then
    log "fish is already the default shell"
    return 0
  fi

  ensure_shell_registered "$fish_bin"

  log "Changing default shell to $fish_bin"
  chsh -s "$fish_bin" "$current_user"

  user_shell="$(current_login_shell)"
  [[ "$user_shell" == "$fish_bin" ]] || die "fish shell change did not persist. Run: chsh -s $fish_bin"
}

apply_dotfiles() {
  local stow_bin="$1"
  local repo_root="$2"

  [[ -x "$stow_bin" ]] || die "stow not found at $stow_bin after Homebrew installation."

  log "Applying dotfiles with GNU Stow"
  "$stow_bin" --restow -d "$repo_root" -t "$HOME" ghostty fish tmux nvim macos
}

apply_caps_lock_escape_remap() {
  local mapping_json=""

  mapping_json="$(caps_lock_escape_mapping_json)"

  command -v /usr/bin/hidutil >/dev/null 2>&1 || die "hidutil is required on macOS."

  log "Applying Caps Lock to Escape remap"
  /usr/bin/hidutil property --set "$mapping_json" >/dev/null
}

load_caps_lock_escape_launch_agent() {
  local uid=""
  local label="com.tmartines.capslock-escape"
  local domain=""
  local agent_path=""

  uid="$(id -u)"
  domain="gui/$uid"
  agent_path="$HOME/Library/LaunchAgents/$label.plist"

  [[ -f "$agent_path" ]] || die "Expected LaunchAgent at $agent_path after stow."

  log "Refreshing Caps Lock to Escape LaunchAgent"

  if ! launchctl bootout "$domain/$label" >/dev/null 2>&1; then
    :
  fi

  if ! launchctl bootstrap "$domain" "$agent_path" >/dev/null 2>&1; then
    warn "Could not bootstrap $label. Run manually: launchctl bootstrap $domain $agent_path"
    return 0
  fi

  if ! launchctl kickstart -k "$domain/$label" >/dev/null 2>&1; then
    warn "Could not kickstart $label. Run manually: launchctl kickstart -k $domain/$label"
  fi
}

find_docker_compose_plugin() {
  local brew_prefix="$1"
  local candidate=""
  local candidates=(
    "$brew_prefix/lib/docker/cli-plugins/docker-compose"
    "$brew_prefix/opt/docker-compose/bin/docker-compose"
    "$brew_prefix/bin/docker-compose"
  )

  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

link_docker_compose_plugin() {
  local brew_prefix="$1"
  local plugin_dir="$HOME/.docker/cli-plugins"
  local plugin_link="$plugin_dir/docker-compose"
  local plugin_target=""
  local current_target=""

  plugin_target="$(find_docker_compose_plugin "$brew_prefix")" || die "docker-compose plugin not found after Homebrew installation."

  mkdir -p "$plugin_dir"

  if [[ -e "$plugin_link" ]] && [[ ! -L "$plugin_link" ]]; then
    die "$plugin_link exists and is not a symlink. Remove it or replace it manually."
  fi

  if [[ -L "$plugin_link" ]]; then
    current_target="$(readlink "$plugin_link" || true)"

    if [[ "$current_target" == "$plugin_target" ]]; then
      return 0
    fi
  fi

  log "Linking docker compose plugin"
  ln -sfn "$plugin_target" "$plugin_link"
}

validate_fish_environment() {
  local fish_bin="$1"
  local docker_bin="$2"

  log "Validating Homebrew tools inside fish"
  DOCKER_BIN="$docker_bin" "$fish_bin" -lc 'test (command -v docker) = $DOCKER_BIN' || die "fish is not using the Homebrew docker CLI at $docker_bin."
  "$fish_bin" -lc 'command -sq colima' || die "fish cannot find colima after bootstrap."
  "$fish_bin" -lc 'docker compose version >/dev/null 2>&1' || die "docker compose is not available inside fish."
  "$fish_bin" -lc 'command -sq tmux' || die "fish cannot find tmux after bootstrap."
  "$fish_bin" -lc 'command -sq nvim' || die "fish cannot find nvim after bootstrap."
  "$fish_bin" -lc 'command -sq tree-sitter' || die "fish cannot find tree-sitter after bootstrap."
  "$fish_bin" -lc 'command -sq rg' || die "fish cannot find ripgrep after bootstrap."
  "$fish_bin" -lc 'command -sq fd' || die "fish cannot find fd after bootstrap."
  "$fish_bin" -lc 'command -sq fzf' || die "fish cannot find fzf after bootstrap."
}

main() {
  local script_dir=""
  local repo_root=""
  local brew_bin=""
  local brew_prefix=""
  local docker_bin=""
  local fish_bin=""

  [[ "${EUID}" -ne 0 ]] || die "Run this bootstrap as your user, not with sudo."
  [[ "$(uname -s)" == "Darwin" ]] || die "This bootstrap only supports macOS."
  [[ "$(uname -m)" == "arm64" ]] || die "This bootstrap currently supports Apple Silicon macOS only."

  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  repo_root="$(cd -- "$script_dir/.." && pwd)"

  brew_bin="$(find_brew || true)"

  if [[ -z "$brew_bin" ]]; then
    install_homebrew
    brew_bin="/opt/homebrew/bin/brew"
  fi

  brew_healthy "$brew_bin" || die "Homebrew at $brew_bin is not usable."

  brew_prefix="$("$brew_bin" --prefix)"
  docker_bin="$brew_prefix/bin/docker"
  fish_bin="$brew_prefix/bin/fish"

  log "Using Homebrew at $brew_bin"
  log "Installing packages from Brewfile"
  "$brew_bin" bundle --file "$repo_root/Brewfile"

  [[ -x "$docker_bin" ]] || die "docker not found at $docker_bin after Homebrew installation."
  link_docker_compose_plugin "$brew_prefix"
  apply_dotfiles "$brew_prefix/bin/stow" "$repo_root"
  apply_caps_lock_escape_remap
  load_caps_lock_escape_launch_agent
  [[ -x "$fish_bin" ]] || die "fish not found at $fish_bin after Homebrew installation."
  validate_fish_environment "$fish_bin" "$docker_bin"
  ensure_default_shell "$fish_bin"

  log "Bootstrap complete. Start a new terminal session or run: exec fish -l"
  log "Then start Colima with: colima start"
  log "Verify the container runtime with: docker ps"
  log "Open Neovim once to install plugins and host-side Mason tooling: nvim"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
