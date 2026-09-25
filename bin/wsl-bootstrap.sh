#!/usr/bin/env bash
# ==============================================================================
# wsl-bootstrap.sh — zero-to-hero provisioning for Windows Subsystem for Linux
#
# Extends linux-bootstrap.sh with WSL-specific configuration:
#   - Windows interop settings
#   - Windows clipboard integration
#   - Font installation on the Windows side
#
# Usage:
#   git clone https://github.com/ne1cc/terminal-configs.git \
#       ~/Github/ne1cc/terminal-configs
#   bash ~/Github/ne1cc/terminal-configs/bin/wsl-bootstrap.sh
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
# 1. Run the base Linux bootstrap
# ------------------------------------------------------------------------------
header "Running base Linux bootstrap..."
bash "$DOTFILES/bin/linux-bootstrap.sh"

# ------------------------------------------------------------------------------
# 2. WSL interop configuration
# ------------------------------------------------------------------------------
header "WSL interop"

# Ensure /etc/wsl.conf has interop enabled
if [[ -f /etc/wsl.conf ]]; then
    if ! grep -q "\[interop\]" /etc/wsl.conf; then
        info "Adding [interop] section to /etc/wsl.conf..."
        sudo tee -a /etc/wsl.conf > /dev/null <<'WSLCONF'

[interop]
enabled = true
appendWindowsPath = true
WSLCONF
        ok "WSL interop configured."
    else
        ok "WSL interop already configured."
    fi
else
    info "Creating /etc/wsl.conf with interop settings..."
    sudo tee /etc/wsl.conf > /dev/null <<'WSLCONF'
[interop]
enabled = true
appendWindowsPath = true
WSLCONF
    ok "WSL interop configured."
fi

# ------------------------------------------------------------------------------
# 3. Windows clipboard fallback
# ------------------------------------------------------------------------------
header "Windows clipboard"
if command -v clip.exe >/dev/null 2>&1; then
    ok "clip.exe available — Windows clipboard integration works."
else
    warn "clip.exe not found. Windows interop may be disabled."
    warn "Check /etc/wsl.conf and restart WSL."
fi

# ------------------------------------------------------------------------------
# 4. Install Nerd Font on Windows side
# ------------------------------------------------------------------------------
header "Nerd Fonts (Windows side)"
WIN_FONT_DIR="/mnt/c/Users/$USER/AppData/Local/Microsoft/Windows/Fonts"
if [[ -d "$WIN_FONT_DIR" ]]; then
    if [[ ! -f "$WIN_FONT_DIR/JetBrainsMonoNFM-Regular.ttf" ]]; then
        info "Copying JetBrainsMono Nerd Font to Windows..."
        cp "$HOME/.local/share/fonts/JetBrainsMonoNFM-Regular.ttf" "$WIN_FONT_DIR/" 2>/dev/null \
            && ok "Font copied to Windows font directory." \
            || warn "Could not copy font. You may need to install it manually on Windows."
    else
        ok "Font already installed on Windows side."
    fi
else
    warn "Windows font directory not found at $WIN_FONT_DIR."
    warn "Install JetBrainsMono Nerd Font manually on Windows for Ghostty/Alacritty."
fi

# ------------------------------------------------------------------------------
# 5. wslview as 'open' fallback
# ------------------------------------------------------------------------------
header "wslview (open URLs in Windows browser)"
if command -v wslview >/dev/null 2>&1; then
    ok "wslview already installed."
else
    info "Installing wslu (provides wslview)..."
    sudo apt install -y wslu 2>/dev/null && ok "wslu installed." || info "wslu not available in apt (using open.exe / cmd.exe fallback)."
fi

echo -e "\n${GREEN}${BOLD}WSL Bootstrap complete!${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Restart WSL: wsl --shutdown (from PowerShell)"
echo "  2. Reopen WSL and run: source ~/.zshrc"
echo "  3. Install Ghostty/Alacritty on the Windows side"
