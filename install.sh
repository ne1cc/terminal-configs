#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Installation Script (macOS)
# ==============================================================================
# Safely links terminal-configs files to their appropriate destinations.
# ==============================================================================

# ANSI Color Codes for premium terminal output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get the absolute directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}${BOLD}==>${NC} ${BOLD}Starting terminal configuration setup...${NC}\n"

# Verify we are running on macOS (since Ghostty/pbcopy are specific to it)
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${YELLOW}[!] Warning: This script is optimized for macOS. Some configurations may need adjustments.${NC}\n"
fi

# Ensure necessary directories exist
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/.config/karabiner"

# Backup and symlink function
link_file() {
    local src="$1"
    local dest="$2"
    local filename
    filename=$(basename "$dest")

    # If the target destination is already a symlink pointing to the correct source, skip
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo -e "  ${GREEN}✓${NC} $filename is already correctly linked."
        return
    fi

    # Handle existing files, directories, or broken symlinks
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        local backup="${dest}.backup_$(date +%Y%m%d_%H%M%S)"
        echo -e "  ${YELLOW}!${NC} Existing $filename found. Backing up to $(basename "$backup")..."
        mv "$dest" "$backup"
    fi

    # Create the symlink
    echo -e "  ${CYAN}→${NC} Linking $filename..."
    ln -s "$src" "$dest"
}

echo -e "${BLUE}${BOLD}==>${NC} ${BOLD}Creating symlinks:${NC}"

# 1. Shell Configs
link_file "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
link_file "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "$SCRIPT_DIR/.zprofile" "$HOME/.zprofile"

# 2. Git Config
link_file "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"

# 3. Tmux Config
link_file "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"

# 4. Ghostty Terminal Config
link_file "$SCRIPT_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"

# 5. Neovim Config
link_file "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"

# 6. Karabiner Config
link_file "$SCRIPT_DIR/.config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"


# 7. Homebrew Bundle Installation
if command -v brew >/dev/null 2>&1; then
    echo -e "\n${BLUE}${BOLD}==>${NC} ${BOLD}Homebrew detected!${NC}"
    echo -e "    Would you like to install/restore all packages from the Brewfile now?"
    read -p "    [y/N]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "  ${CYAN}→${NC} Running: brew bundle --file=\"$SCRIPT_DIR/Brewfile\""
        brew bundle --file="$SCRIPT_DIR/Brewfile"
    else
        echo -e "  ${YELLOW}!${NC} Skipping package installation. You can run it manually later via:"
        echo -e "    ${CYAN}brew bundle --file=\"$SCRIPT_DIR/Brewfile\"${NC}"
    fi
else
    echo -e "\n${YELLOW}[!] Homebrew is not installed.${NC}"
    echo -e "    Install it from ${CYAN}https://brew.sh/${NC} then run:"
    echo -e "    ${CYAN}brew bundle --file=\"$SCRIPT_DIR/Brewfile\"${NC}"
fi

echo -e "\n${GREEN}${BOLD}✓ Setup Complete!${NC}"
echo -e "${CYAN}Please restart your terminal session or run:${NC} source ~/.zshrc"
echo -e "\n${BLUE}${BOLD}Note:${NC} Ensure you have installed other environment details if not already done:"
echo -e "  - Oh My Zsh: ${CYAN}sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"${NC}"
echo -e "  - Powerlevel10k theme: ${CYAN}git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/Applications/powerlevel10k${NC}"

