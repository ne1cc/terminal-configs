#!/usr/bin/env bash
# ==============================================================================
# linux-bootstrap.sh — zero-to-hero provisioning for Ubuntu/Debian
#
# Usage (on a fresh machine):
#   git clone https://github.com/n1ecC/terminal-configs.git \
#       ~/Github/n1ecC/terminal-configs
#   bash ~/Github/n1ecC/terminal-configs/bin/linux-bootstrap.sh
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
# 1. System packages (apt)
# ------------------------------------------------------------------------------
header "System packages (apt)"
sudo apt update
sudo apt install -y \
    build-essential \
    curl \
    git \
    scrot \
    wget \
    xclip \
    xsel \
    xdg-utils \
    zsh
ok "System packages installed."

# ------------------------------------------------------------------------------
# 2. Linuxbrew
# ------------------------------------------------------------------------------
header "Linuxbrew"
if ! command -v brew >/dev/null 2>&1; then
    info "Installing Linuxbrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
else
    ok "Linuxbrew already installed."
fi

# ------------------------------------------------------------------------------
# 3. Brew packages
# ------------------------------------------------------------------------------
header "Linuxbrew packages"
echo -e "    Install all packages from Brewfile.linux?"
read -p "    [y/N]: " -n 1 -r; echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    brew bundle --file="$DOTFILES/Brewfile.linux"
else
    warn "Skipped. Run: brew bundle --file=\"$DOTFILES/Brewfile.linux\""
fi

# ------------------------------------------------------------------------------
# 4. Oh My Zsh
# ------------------------------------------------------------------------------
header "Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    ok "Already installed."
else
    info "Installing Oh My Zsh (unattended)..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ------------------------------------------------------------------------------
# 5. Powerlevel10k
# ------------------------------------------------------------------------------
header "Powerlevel10k"
P10K_DIR="$HOME/.local/share/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
    ok "Already cloned at $P10K_DIR."
else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

OMZ_CUSTOM_THEMES="$HOME/.oh-my-zsh/custom/themes"
mkdir -p "$OMZ_CUSTOM_THEMES"
if [[ ! -L "$OMZ_CUSTOM_THEMES/powerlevel10k" && ! -d "$OMZ_CUSTOM_THEMES/powerlevel10k" ]]; then
    ln -s "$P10K_DIR" "$OMZ_CUSTOM_THEMES/powerlevel10k"
    ok "Symlinked powerlevel10k to $OMZ_CUSTOM_THEMES/powerlevel10k."
else
    ok "Symlink/directory for powerlevel10k already exists."
fi

# ------------------------------------------------------------------------------
# 6. Nerd Fonts
# ------------------------------------------------------------------------------
header "Nerd Fonts"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if [[ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]]; then
    info "Installing JetBrainsMono Nerd Font..."
    curl -fsSL -o /tmp/JetBrainsMono.tar.xz \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR"
    rm -f /tmp/JetBrainsMono.tar.xz
    fc-cache -fv >/dev/null 2>&1
    ok "JetBrainsMono Nerd Font installed."
else
    ok "JetBrainsMono Nerd Font already installed."
fi

# ------------------------------------------------------------------------------
# 7. Required directories
# ------------------------------------------------------------------------------
header "Directories"
for d in "$HOME/.config" "$HOME/.config/ghostty" \
         "$HOME/Pictures/Screenshots" "$HOME/bin" "$HOME/.local/bin"; do
    mkdir -p "$d" && ok "$d"
done

# ------------------------------------------------------------------------------
# 8. Stow dotfiles (install.sh also runs setup-github-workspace)
# ------------------------------------------------------------------------------
header "Symlinking dotfiles via Stow"
cd "$DOTFILES"

STOW_TARGETS=(
    "$HOME/.zshrc"
    "$HOME/.zprofile"
    "$HOME/.gitconfig"
    "$HOME/.p10k.zsh"
    "$HOME/.tmux.conf"
    "$HOME/.config/ghostty/config"
    "$HOME/.config/nvim"
)

CONFLICTING=()
for t in "${STOW_TARGETS[@]}"; do
    if [[ -L "$t" ]]; then
        target_dest=$(readlink "$t")
        if [[ "$target_dest" == /* ]]; then
            CONFLICTING+=("$t")
        fi
    fi
done

if [[ ${#CONFLICTING[@]} -gt 0 ]]; then
    echo ""
    warn "The following paths are absolute symlinks not managed by Stow:"
    for t in "${CONFLICTING[@]}"; do
        echo "      $t -> $(readlink "$t")"
    done
    echo ""
    echo -e "    Remove them and let Stow re-create them?"
    read -p "    [y/N]: " -n 1 -r; echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for t in "${CONFLICTING[@]}"; do
            rm -rf "$t" && info "Removed $t"
        done
    else
        warn "Skipped removal. Stow will likely fail — re-run manually when ready."
    fi
fi

# install.sh restows via GNU Stow, then links Claude/config/bin and installs TPM.
"$DOTFILES/install.sh"
ok "All dotfiles linked."

# ------------------------------------------------------------------------------
# 9. Git credential helper
# ------------------------------------------------------------------------------
header "Git credential helper"
git config --global credential.helper store
ok "Git credential helper set to 'store'."

# ------------------------------------------------------------------------------
# 10. fnm / Node
# ------------------------------------------------------------------------------
header "Node.js (fnm)"
if command -v fnm >/dev/null 2>&1; then
    ok "fnm already installed."
    info "Installing Node.js LTS..."
    fnm install --lts
    fnm default "$(fnm list-remote | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+' | tail -1)"
else
    warn "fnm not found — should have installed via Brewfile.linux."
    warn "To install manually: brew install fnm"
fi

# Set zsh as default shell
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    header "Default shell"
    info "Setting zsh as default shell..."
    chsh -s "$(command -v zsh)"
    ok "Default shell changed to $(command -v zsh)."
fi

echo -e "\n${GREEN}${BOLD}Bootstrap complete!${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Log out and back in (or run: chsh -s \$(which zsh))"
echo "  2. Run: source ~/.zshrc"
echo "  3. Run: tmux source ~/.tmux.conf"
