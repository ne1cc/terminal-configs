#!/usr/bin/env bash
# ==============================================================================
# mac-bootstrap.sh — zero-to-hero provisioning for a new Apple Silicon Mac
#
# Usage (on a fresh machine):
#   git clone https://github.com/consciouspenguin/terminal-configs.git \
#       ~/Github/terminal-configs
#   bash ~/Github/terminal-configs/bin/mac-bootstrap.sh
# ==============================================================================

set -e

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'
BOLD='\033[1m'; NC='\033[0m'

header() { echo -e "\n${BLUE}${BOLD}==>${NC} ${BOLD}$*${NC}"; }
ok()     { echo -e "  ${GREEN}✓${NC} $*"; }
info()   { echo -e "  ${CYAN}→${NC} $*"; }
warn()   { echo -e "  ${YELLOW}!${NC} $*"; }

DOTFILES="$HOME/Github/terminal-configs"

# ------------------------------------------------------------------------------
# 1. Homebrew
# ------------------------------------------------------------------------------
header "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv bash)"
else
    ok "Homebrew already installed."
fi

# ------------------------------------------------------------------------------
# 2. Taps + packages
# ------------------------------------------------------------------------------
header "Homebrew taps"
for tap in antoniorodr/memo koekeishiya/formulae steipete/tap yakitrak/yakitrak; do
    brew tap | grep -q "^${tap}$" && ok "$tap already active." || brew tap "$tap"
done

header "Homebrew packages"
echo -e "    Install all packages from Brewfile?"
read -p "    [y/N]: " -n 1 -r; echo ""
[[ $REPLY =~ ^[Yy]$ ]] && brew bundle --file="$DOTFILES/Brewfile" \
    || warn "Skipped. Run: brew bundle --file=\"$DOTFILES/Brewfile\""

# ------------------------------------------------------------------------------
# 3. Oh My Zsh
# ------------------------------------------------------------------------------
header "Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "Already installed."
else
    info "Installing Oh My Zsh (unattended)..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ------------------------------------------------------------------------------
# 4. Powerlevel10k
# ------------------------------------------------------------------------------
header "Powerlevel10k"
P10K_DIR="$HOME/Applications/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
    ok "Already cloned at $P10K_DIR."
else
    mkdir -p "$HOME/Applications"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# ------------------------------------------------------------------------------
# 5. Required directories
# ------------------------------------------------------------------------------
header "Directories"
for d in "$HOME/.config" "$HOME/.config/ghostty" "$HOME/.config/karabiner" \
         "$HOME/Pictures/Screenshots" "$HOME/bin"; do
    mkdir -p "$d" && ok "$d"
done

# ------------------------------------------------------------------------------
# 6. Stow dotfiles
# ------------------------------------------------------------------------------
header "Symlinking dotfiles via Stow"
cd "$DOTFILES"
stow --target="$HOME" --restow .
ok "All dotfiles linked."

# ==============================================================================
# Setup Claude Code global configurations (since ~/.claude is ignored by Stow)
# ==============================================================================
CLAUDE_DIR="$HOME/.claude"
CLAUDE_CMD_DIR="$CLAUDE_DIR/commands"

info "Setting up global Claude Code configurations..."
mkdir -p "$CLAUDE_CMD_DIR"

# Link global CLAUDE.md
GLOBAL_CLAUDE_DEST="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$GLOBAL_CLAUDE_DEST" ] && [ ! -L "$GLOBAL_CLAUDE_DEST" ]; then
    BACKUP="$GLOBAL_CLAUDE_DEST.backup_$(date +%Y%m%d_%H%M%S)"
    warn "Backing up existing global CLAUDE.md to $BACKUP"
    mv "$GLOBAL_CLAUDE_DEST" "$BACKUP"
fi
ln -sf "$DOTFILES/claude-code/CLAUDE.md" "$GLOBAL_CLAUDE_DEST"
ok "Symlinked global CLAUDE.md"

# Link slash commands
for cmd in "$DOTFILES/claude-code/commands"/*.md; do
    cmd_name=$(basename "$cmd")
    if [ "$cmd_name" != "README.md" ]; then
        dest="$CLAUDE_CMD_DIR/$cmd_name"
        if [ -f "$dest" ] && [ ! -L "$dest" ]; then
            BACKUP="$dest.backup_$(date +%Y%m%d_%H%M%S)"
            warn "Backing up existing command $cmd_name to $BACKUP"
            mv "$dest" "$BACKUP"
        fi
        ln -sf "$cmd" "$dest"
        ok "Symlinked command: /$cmd_name"
    fi
done

# ==============================================================================
# Setup Antigravity / Gemini skills and global markdown rules
# ==============================================================================
GEMINI_DIR="$HOME/.gemini/config"
GEMINI_SKILLS_DIR="$GEMINI_DIR/skills"

info "Setting up global Antigravity / Gemini skills..."
mkdir -p "$GEMINI_SKILLS_DIR"

if [ -f "$DOTFILES/.gemini/GEMINI.md" ]; then
    ln -sf "$DOTFILES/.gemini/GEMINI.md" "$HOME/GEMINI.md"
    ln -sf "$DOTFILES/.gemini/GEMINI.md" "$GEMINI_DIR/GEMINI.md"
    ok "Symlinked global GEMINI.md"
fi

if [ -d "$DOTFILES/.gemini/skills" ]; then
    for skill in "$DOTFILES/.gemini/skills"/*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            dest="$GEMINI_SKILLS_DIR/$skill_name"
            ln -sfn "$skill" "$dest"
        fi
    done
    ok "Symlinked $(ls -1 "$DOTFILES/.gemini/skills" | wc -l | tr -d ' ') skills to $GEMINI_SKILLS_DIR"
fi

# ------------------------------------------------------------------------------
# 7. fnm / Node
# ------------------------------------------------------------------------------
header "Node.js (fnm)"
command -v fnm >/dev/null 2>&1 \
    && ok "fnm installed. Run 'fnm install --lts' if needed." \
    || warn "fnm not found — should have installed via Brewfile."

echo -e "\n${GREEN}${BOLD}✓ Bootstrap complete!${NC}"
echo -e "${CYAN}Restart Ghostty or run:${NC} source ~/.zshrc"
