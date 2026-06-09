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

# Detect any existing symlinks at the target paths that stow doesn't own.
# This happens when dotfiles were previously set up manually with `ln -s`
# using absolute paths. Stow only recognises the relative symlinks it creates
# itself, so it refuses to overwrite absolute ones even when they point to the
# right place. On a fresh machine this is never an issue; on a machine with a
# prior manual setup you'll see "existing target is not owned by stow" errors.
STOW_TARGETS=(
    "$HOME/.zshrc"
    "$HOME/.zprofile"
    "$HOME/.gitconfig"
    "$HOME/.p10k.zsh"
    "$HOME/.tmux.conf"
    "$HOME/.config/ghostty/config"
    "$HOME/.config/karabiner/karabiner.json"
    "$HOME/.config/nvim"
)

CONFLICTING=()
for t in "${STOW_TARGETS[@]}"; do
    if [[ -L "$t" ]]; then
        target_dest=$(readlink "$t")
        # absolute symlinks start with /
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
    echo -e "    Stow needs to replace these with its own relative symlinks."
    echo -e "    This is safe — all files still live in $DOTFILES."
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

stow --target="$HOME" --restow .
ok "All dotfiles linked."

# ------------------------------------------------------------------------------
# 7. fnm / Node
# ------------------------------------------------------------------------------
header "Node.js (fnm)"
command -v fnm >/dev/null 2>&1 \
    && ok "fnm installed. Run 'fnm install --lts' if needed." \
    || warn "fnm not found — should have installed via Brewfile."

echo -e "\n${GREEN}${BOLD}✓ Bootstrap complete!${NC}"
echo -e "${CYAN}Restart Ghostty or run:${NC} source ~/.zshrc"
