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

# ------------------------------------------------------------------------------
# 6. Windows Shared Dev Drive / GitHub Workspace Integration
# ------------------------------------------------------------------------------
header "Windows Shared GitHub Workspace"
SHARED_GITHUB_CANDIDATES=("/mnt/x/Github" "/mnt/d/Github" "/mnt/z/Github")
DETECTED_SHARED=""

for candidate in "${SHARED_GITHUB_CANDIDATES[@]}"; do
    if [[ -d "$candidate" ]]; then
        DETECTED_SHARED="$candidate"
        break
    fi
done

if [[ -n "$DETECTED_SHARED" ]]; then
    info "Found Windows shared GitHub workspace at $DETECTED_SHARED."
    if [[ -L "$HOME/Github" && "$(readlink "$HOME/Github")" == "$DETECTED_SHARED" ]]; then
        ok "$HOME/Github already points to $DETECTED_SHARED."
    elif [[ ! -e "$HOME/Github" ]]; then
        ln -s "$DETECTED_SHARED" "$HOME/Github"
        ok "Linked $HOME/Github -> $DETECTED_SHARED (zero duplicate repos)."
    elif [[ -d "$HOME/Github" && ! -L "$HOME/Github" ]]; then
        info "Existing $HOME/Github directory found. Linking to $DETECTED_SHARED if empty..."
        if [[ -z "$(ls -A "$HOME/Github" 2>/dev/null)" ]]; then
            rmdir "$HOME/Github"
            ln -s "$DETECTED_SHARED" "$HOME/Github"
            ok "Linked $HOME/Github -> $DETECTED_SHARED."
        else
            warn "$HOME/Github contains files. Move them to $DETECTED_SHARED and link manually:"
            warn "  mv $HOME/Github $HOME/Github.bak && ln -s $DETECTED_SHARED $HOME/Github"
        fi
    fi
else
    info "No Windows shared Dev Drive detected (/mnt/x/Github, /mnt/d/Github). Using local ~/Github."
fi

echo -e "\n${GREEN}${BOLD}WSL Bootstrap complete!${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Restart WSL: wsl --shutdown (from PowerShell)"
echo "  2. Reopen WSL and run: source ~/.zshrc"
echo "  3. Install Ghostty/Alacritty on the Windows side"
echo "  4. On Windows, run: powershell -ExecutionPolicy Bypass -File .\\windows\\setup.ps1"

