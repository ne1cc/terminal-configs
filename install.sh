#!/usr/bin/env bash
# ==============================================================================
# install.sh — re-link dotfiles on this machine using GNU Stow
#
# For first-time setup on a new machine, use bin/mac-bootstrap.sh instead.
# ==============================================================================

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Symlinking dotfiles from $DOTFILES → $HOME"
cd "$DOTFILES"
stow --target="$HOME" --restow .
echo "Done. Restart your terminal or run: source ~/.zshrc"
