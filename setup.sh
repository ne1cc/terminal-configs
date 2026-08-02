#!/usr/bin/env zsh
# setup.sh - Reproducible Symlink Setup Script for macOS, Linux, and Windows (WSL2)

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "=========================================="
echo " Terminal Configs Reproducible Installer  "
echo "=========================================="

mkdir -p "$CONFIG_DIR"

echo "==> Linking Home Directory Dotfiles..."
ln -sf "$REPO_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$REPO_DIR/.zprofile" "$HOME/.zprofile"
ln -sf "$REPO_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
ln -sf "$REPO_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sf "$REPO_DIR/.taskrc" "$HOME/.taskrc"

echo "==> Linking ~/.config Folders..."
ln -sfn "$REPO_DIR/.config/nvim" "$CONFIG_DIR/nvim"
ln -sfn "$REPO_DIR/.config/ghostty" "$CONFIG_DIR/ghostty"
ln -sfn "$REPO_DIR/.config/alacritty" "$CONFIG_DIR/alacritty"
ln -sfn "$REPO_DIR/.config/lazygit" "$CONFIG_DIR/lazygit"

echo "==> Linking ~/bin Scripts..."
mkdir -p "$HOME/bin"
for script in "$REPO_DIR/bin/"*; do
  if [ -f "$script" ]; then
    ln -sf "$script" "$HOME/bin/$(basename "$script")"
  fi
done

# OS-Specific Configs
if [[ "$(uname)" == "Darwin" ]]; then
  echo "==> macOS detected: Linking Karabiner..."
  ln -sfn "$REPO_DIR/.config/karabiner" "$CONFIG_DIR/karabiner"
fi

# Ensure Tmux Plugin Manager (TPM) is installed
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "==> Installing Tmux Plugin Manager (TPM)..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

echo "=========================================="
echo "✓ All configurations symlinked cleanly!"
echo "=========================================="
