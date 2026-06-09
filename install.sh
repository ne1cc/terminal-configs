#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Installation Script (macOS)
# ==============================================================================
# Safely symlinks terminal-configs files, installs shell framework + theme,
# and restores all Homebrew packages.
# ==============================================================================

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

header() { echo -e "\n${BLUE}${BOLD}==>${NC} ${BOLD}$*${NC}"; }
ok()     { echo -e "  ${GREEN}✓${NC} $*"; }
info()   { echo -e "  ${CYAN}→${NC} $*"; }
warn()   { echo -e "  ${YELLOW}!${NC} $*"; }
err()    { echo -e "  ${RED}✗${NC} $*"; }

echo -e "${BLUE}${BOLD}==>${NC} ${BOLD}Starting terminal configuration setup...${NC}"

if [[ "$OSTYPE" != "darwin"* ]]; then
    warn "This script is optimised for macOS. Some steps may need adjustment."
fi

# ------------------------------------------------------------------------------
# 1. Homebrew
# ------------------------------------------------------------------------------
header "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Apple Silicon path
    eval "$(/opt/homebrew/bin/brew shellenv bash)" 2>/dev/null || true
else
    ok "Homebrew already installed."
fi

# Add required taps before running bundle
header "Homebrew taps"
TAPS=(
    "antoniorodr/memo"
    "koekeishiya/formulae"
    "steipete/tap"
    "yakitrak/yakitrak"
)
for tap in "${TAPS[@]}"; do
    if brew tap | grep -q "^${tap}$"; then
        ok "Tap ${tap} already active."
    else
        info "Adding tap: ${tap}..."
        brew tap "$tap"
    fi
done

# ------------------------------------------------------------------------------
# 2. Brew Bundle
# ------------------------------------------------------------------------------
header "Homebrew packages (Brewfile)"
echo -e "    Install / restore all packages from the Brewfile?"
read -p "    [y/N]: " -n 1 -r; echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Running: brew bundle --file=\"$SCRIPT_DIR/Brewfile\""
    brew bundle --file="$SCRIPT_DIR/Brewfile"
else
    warn "Skipped. Run manually: brew bundle --file=\"$SCRIPT_DIR/Brewfile\""
fi

# ------------------------------------------------------------------------------
# 3. Oh My Zsh
# ------------------------------------------------------------------------------
header "Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "Oh My Zsh already installed."
else
    info "Installing Oh My Zsh (unattended)..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ------------------------------------------------------------------------------
# 4. Powerlevel10k theme
# ------------------------------------------------------------------------------
header "Powerlevel10k"
P10K_DIR="$HOME/Applications/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
    ok "Powerlevel10k already cloned at $P10K_DIR."
else
    info "Cloning Powerlevel10k into $P10K_DIR..."
    mkdir -p "$HOME/Applications"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# ------------------------------------------------------------------------------
# 5. Required directories
# ------------------------------------------------------------------------------
header "Directories"
DIRS=(
    "$HOME/.config"
    "$HOME/.config/ghostty"
    "$HOME/.config/karabiner"
    "$HOME/Pictures/Screenshots"   # used by snap() in .zshrc
)
for d in "${DIRS[@]}"; do
    mkdir -p "$d" && ok "$d"
done

# ------------------------------------------------------------------------------
# 6. Symlinks
# ------------------------------------------------------------------------------
link_file() {
    local src="$1"
    local dest="$2"
    local name
    name=$(basename "$dest")

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        ok "$name already correctly linked."
        return
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        local backup="${dest}.backup_$(date +%Y%m%d_%H%M%S)"
        warn "Existing $name — backing up to $(basename "$backup")"
        mv "$dest" "$backup"
    fi

    info "Linking $name..."
    ln -s "$src" "$dest"
}

header "Symlinks"
link_file "$SCRIPT_DIR/.zshrc"                          "$HOME/.zshrc"
link_file "$SCRIPT_DIR/.p10k.zsh"                       "$HOME/.p10k.zsh"
link_file "$SCRIPT_DIR/.zprofile"                       "$HOME/.zprofile"
link_file "$SCRIPT_DIR/.gitconfig"                      "$HOME/.gitconfig"
link_file "$SCRIPT_DIR/.tmux.conf"                      "$HOME/.tmux.conf"
link_file "$SCRIPT_DIR/.config/ghostty/config"          "$HOME/.config/ghostty/config"
link_file "$SCRIPT_DIR/.config/nvim"                    "$HOME/.config/nvim"
link_file "$SCRIPT_DIR/.config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

# ------------------------------------------------------------------------------
# 7. fnm / Node
# ------------------------------------------------------------------------------
header "Node.js (fnm)"
if command -v fnm >/dev/null 2>&1; then
    ok "fnm is installed. Run 'fnm install --lts' to get the latest LTS if needed."
else
    warn "fnm not found. It should have been installed via the Brewfile above."
fi

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}${BOLD}✓ Setup complete!${NC}"
echo -e "${CYAN}Restart your terminal or run:${NC} source ~/.zshrc"
