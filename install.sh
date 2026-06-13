#!/usr/bin/env bash
# ==============================================================================
# install.sh — re-link dotfiles on this machine using GNU Stow
#
# For first-time setup on a new machine, use the appropriate bootstrap script:
#   macOS:  bin/mac-bootstrap.sh
#   Linux:  bin/linux-bootstrap.sh
#   WSL:    bin/wsl-bootstrap.sh
# ==============================================================================

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Symlinking dotfiles from $DOTFILES → $HOME"
cd "$DOTFILES"
stow --target="$HOME" --restow .

# ==============================================================================
# Setup Claude Code global configurations (since ~/.claude is ignored by Stow)
# ==============================================================================
CLAUDE_DIR="$HOME/.claude"
CLAUDE_CMD_DIR="$CLAUDE_DIR/commands"

echo "Setting up global Claude Code configurations..."
mkdir -p "$CLAUDE_CMD_DIR"

# Link global CLAUDE.md
GLOBAL_CLAUDE_DEST="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$GLOBAL_CLAUDE_DEST" ] && [ ! -L "$GLOBAL_CLAUDE_DEST" ]; then
    BACKUP="$GLOBAL_CLAUDE_DEST.backup_$(date +%Y%m%d_%H%M%S)"
    echo "  Backing up existing global CLAUDE.md to $BACKUP"
    mv "$GLOBAL_CLAUDE_DEST" "$BACKUP"
fi
ln -sf "$DOTFILES/claude-code/CLAUDE.md" "$GLOBAL_CLAUDE_DEST"
echo "  Symlinked $GLOBAL_CLAUDE_DEST -> $DOTFILES/claude-code/CLAUDE.md"

# Link slash commands
for cmd in "$DOTFILES/claude-code/commands"/*.md; do
    cmd_name=$(basename "$cmd")
    if [ "$cmd_name" != "README.md" ]; then
        dest="$CLAUDE_CMD_DIR/$cmd_name"
        if [ -f "$dest" ] && [ ! -L "$dest" ]; then
            BACKUP="$dest.backup_$(date +%Y%m%d_%H%M%S)"
            echo "  Backing up existing command $cmd_name to $BACKUP"
            mv "$dest" "$BACKUP"
        fi
        ln -sf "$cmd" "$dest"
        echo "  Symlinked $dest -> $cmd"
    fi
done

echo "Done. Restart your terminal or run: source ~/.zshrc"

