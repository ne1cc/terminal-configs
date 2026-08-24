#!/usr/bin/env bash
# ==============================================================================
# mac-bootstrap.sh — zero-to-hero provisioning for a new Apple Silicon Mac
#
# Usage (on a fresh machine):
#   git clone https://github.com/n1ecC/terminal-configs.git \
#       ~/Github/n1ecC/terminal-configs
#   bash ~/Github/n1ecC/terminal-configs/bin/mac-bootstrap.sh
# ==============================================================================

set -e

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'
BOLD='\033[1m'; NC='\033[0m'

header() { echo -e "\n${BLUE}${BOLD}==>${NC} ${BOLD}$*${NC}"; }
ok()     { echo -e "  ${GREEN}✓${NC} $*"; }
info()   { echo -e "  ${CYAN}→${NC} $*"; }
warn()   { echo -e "  ${YELLOW}!${NC} $*"; }

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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
         "$HOME/Pictures/Screenshots" "$HOME/bin" \
         "$HOME/Github/n1ecC" "$HOME/Github/explore" "$HOME/Github/workspace" \
         "$HOME/Github/archive" "$HOME/Github/_tools"; do
    mkdir -p "$d" && ok "$d"
done

# ------------------------------------------------------------------------------
# 6. Stow dotfiles
# ------------------------------------------------------------------------------
header "Symlinking dotfiles via Stow"
cd "$DOTFILES"
stow --target="$HOME" --restow .
ok "All dotfiles linked."

"$DOTFILES/bin/link-stow-extras.sh"
ok "Stow-excluded paths linked (nvim, bin, taskrc)."

"$DOTFILES/bin/link-claude-code.sh"
ok "Claude Code global configuration linked."

"$DOTFILES/bin/link-agent-skills.sh"
ok "Agent skills linked for Gemini, Claude Code, Codex, and Cursor."

"$DOTFILES/bin/setup-github-workspace"
ok "Github workspace layout and _tools symlinks configured."

# ------------------------------------------------------------------------------
# 7. fnm / Node
# ------------------------------------------------------------------------------
header "Node.js (fnm)"
command -v fnm >/dev/null 2>&1 \
    && ok "fnm installed. Run 'fnm install --lts' if needed." \
    || warn "fnm not found — should have installed via Brewfile."

echo -e "\n${GREEN}${BOLD}✓ Bootstrap complete!${NC}"
echo -e "${CYAN}Restart Ghostty or run:${NC} source ~/.zshrc"
