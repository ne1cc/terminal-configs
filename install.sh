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
# setup.sh creates absolute ln -s links; GNU Stow treats those as foreign
# and aborts. Keep going — the explicit link loop below repairs them.
if ! stow --target="$HOME" --restow .; then
    echo "Stow reported conflicts (usually existing absolute symlinks). Continuing with explicit links."
fi

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
for cfg in nvim ghostty alacritty lazygit yazi starship.toml glow; do
    if [ -e "$DOTFILES/.config/$cfg" ]; then
        dest="$CONFIG_DIR/$cfg"
        # ln -sfn will not replace a real directory; it nests a symlink inside.
        if [ -d "$dest" ] && [ ! -L "$dest" ]; then
            echo "  Replacing directory $dest with symlink"
            rm -rf "$dest"
        fi
        ln -sfn "$DOTFILES/.config/$cfg" "$dest"
        echo "  Symlinked $dest -> $DOTFILES/.config/$cfg"
    fi
done

for script in "$DOTFILES"/bin/*; do
    if [ -f "$script" ]; then
        sname=$(basename "$script")
        ln -sf "$script" "$HOME/bin/$sname"
    fi
done

# ------------------------------------------------------------------------------
# Tmux plugin manager (TPM) + plugins
# .tmux.conf ends with `run '~/.tmux/plugins/tpm/tpm'`, so TPM must be present.
# It is NOT vendored here (it carries its own .git); clone at install time and
# install resurrect / continuum / logging non-interactively.
# ------------------------------------------------------------------------------
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "Installing TPM → $TPM_DIR"
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
echo "Installing tmux plugins via TPM"
"$TPM_DIR/bin/install_plugins" || true

echo "Done. Restart your terminal or run: source ~/.zshrc"

