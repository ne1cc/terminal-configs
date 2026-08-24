#!/usr/bin/env bash
# ==============================================================================
# install.sh — re-link dotfiles on this machine using GNU Stow
#
# For first-time setup on a new machine, use the appropriate bootstrap script:
#   macOS:  bin/mac-bootstrap.sh
#   Linux:  bin/linux-bootstrap.sh
#   WSL:    bin/wsl-bootstrap.sh
# ==============================================================================

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Symlinking dotfiles from $DOTFILES → $HOME"
cd "$DOTFILES"

set +e
stow --target="$HOME" --restow .
stow_status=$?
set -euo pipefail

if [[ $stow_status -ne 0 ]]; then
  echo "Note: stow reported conflicts (usually existing absolute symlinks). Continuing with explicit link scripts."
fi

"$DOTFILES/bin/link-stow-extras.sh"
"$DOTFILES/bin/link-claude-code.sh"
"$DOTFILES/bin/link-agent-skills.sh"
"$DOTFILES/bin/setup-github-workspace"

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  echo "Installing TPM → $TPM_DIR"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

echo "Installing tmux plugins via TPM"
"$TPM_DIR/bin/install_plugins" || true

echo "Done. Restart your terminal or run: source ~/.zshrc"
