#!/usr/bin/env bash
# link-stow-extras.sh — link paths GNU Stow skips (.stow-local-ignore).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$HOME/.config"

link_path() {
  local source="$1"
  local destination="$2"

  if [[ -L "$destination" && "$(readlink "$destination")" == "$source" ]]; then
    printf '  unchanged: %s\n' "$destination"
    return
  fi

  if [[ -e "$destination" || -L "$destination" ]]; then
    rm -rf "$destination"
  fi

  mkdir -p "$(dirname "$destination")"
  ln -sfn "$source" "$destination"
  printf '  linked: %s\n' "$destination"
}

printf '==> Linking Stow-excluded paths from %s\n' "$REPO_DIR"

mkdir -p "$CONFIG_DIR"

link_path "$REPO_DIR/.config/nvim" "$CONFIG_DIR/nvim"

# ~/bin may already be a directory symlink to $REPO_DIR/bin (common on this host).
# Linking files into that path would replace the real scripts with self-symlinks.
repo_bin="$(cd "$REPO_DIR/bin" && pwd -P)"
if [[ -L "$HOME/bin" || -d "$HOME/bin" ]]; then
  home_bin="$(cd "$HOME/bin" && pwd -P)"
else
  home_bin=""
fi

if [[ -n "$home_bin" && "$home_bin" == "$repo_bin" ]]; then
  printf '  unchanged: %s (already points at repo bin)\n' "$HOME/bin"
else
  mkdir -p "$HOME/bin"
  for script in "$REPO_DIR"/bin/*; do
    [[ -f "$script" ]] || continue
    link_path "$script" "$HOME/bin/$(basename "$script")"
  done
fi

if [[ -f "$REPO_DIR/.taskrc.template" ]]; then
  theme_path=""
  for candidate in \
    "/opt/homebrew/share/doc/task/rc/dark-256.theme" \
    "/usr/local/share/doc/task/rc/dark-256.theme" \
    "/usr/share/doc/task/rc/dark-256.theme"; do
    if [[ -f "$candidate" ]]; then
      theme_path="$candidate"
      break
    fi
  done

  if [[ -n "$theme_path" ]]; then
    sed "s|__THEME_PATH__|$theme_path|g" "$REPO_DIR/.taskrc.template" > "$REPO_DIR/.taskrc"
  else
    sed "/__THEME_PATH__/d" "$REPO_DIR/.taskrc.template" > "$REPO_DIR/.taskrc"
  fi
  link_path "$REPO_DIR/.taskrc" "$HOME/.taskrc"
fi

legacy_ghostty_config="$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
if [[ "$(uname -s)" == "Darwin" && -L "$legacy_ghostty_config" && "$(readlink "$legacy_ghostty_config")" == "$REPO_DIR/.config/ghostty/config" ]]; then
  rm "$legacy_ghostty_config"
  printf '  removed obsolete Ghostty config: %s\n' "$legacy_ghostty_config"
fi

printf 'Done linking Stow-excluded paths.\n'
