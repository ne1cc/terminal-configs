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

# ==============================================================================
# Setup ~/.config directories and helper binaries
# ==============================================================================
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR" "$HOME/bin"

echo "Linking ~/.config directories and tools..."
for cfg in nvim ghostty alacritty lazygit yazi starship.toml; do
    if [ -e "$DOTFILES/.config/$cfg" ]; then
        ln -sfn "$DOTFILES/.config/$cfg" "$CONFIG_DIR/$cfg"
        echo "  Symlinked $CONFIG_DIR/$cfg -> $DOTFILES/.config/$cfg"
    fi
done

for script in "$DOTFILES"/bin/*; do
    if [ -f "$script" ]; then
        sname=$(basename "$script")
        ln -sf "$script" "$HOME/bin/$sname"
    fi
done

echo "Done. Restart your terminal or run: source ~/.zshrc"

