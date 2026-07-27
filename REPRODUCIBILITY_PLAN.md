# Cross-Platform Terminal Configs Setup & Reproducibility Guide

This document provides a step-by-step guide and reproducible automated installation plan to set up all terminal configurations on any machine running **macOS**, **Linux (Ubuntu/Debian/Arch)**, or **Windows (WSL2)**.

---

## 1. Directory Architecture

All dotfiles and application configuration files are centralized in this repository (`terminal-configs`). Symlinks are created from the system default locations (`~` and `~/.config`) back to this repository.

| Config Component | Repo Location | Symlink Target |
| :--- | :--- | :--- |
| **Zsh RC** | `.zshrc` | `~/.zshrc` |
| **Zsh Profile** | `.zprofile` | `~/.zprofile` |
| **Powerlevel10k** | `.p10k.zsh` | `~/.p10k.zsh` |
| **Tmux Config** | `.tmux.conf` | `~/.tmux.conf` |
| **Git Config** | `.gitconfig` | `~/.gitconfig` |
| **Neovim** | `.config/nvim` | `~/.config/nvim` |
| **Ghostty** | `.config/ghostty` | `~/.config/ghostty` |
| **Karabiner** *(macOS only)* | `.config/karabiner` | `~/.config/karabiner` |
| **Alacritty** | `.config/alacritty` | `~/.config/alacritty` |

---

## 2. Fast Setup (Automated Symlinking Script)

Run the included setup script from the root of the `terminal-configs` repo to link all dotfiles:

```bash
#!/usr/bin/env zsh
# setup.sh - Reproducible Symlink Setup Script

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
CONFIG_DIR="$HOME/.config"

mkdir -p "$CONFIG_DIR"

echo "==> Creating Home Directory Symlinks..."
ln -sf "$REPO_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$REPO_DIR/.zprofile" "$HOME/.zprofile"
ln -sf "$REPO_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
ln -sf "$REPO_DIR/.gitconfig" "$HOME/.gitconfig"

echo "==> Creating ~/.config Symlinks..."
ln -sfn "$REPO_DIR/.config/nvim" "$CONFIG_DIR/nvim"
ln -sfn "$REPO_DIR/.config/ghostty" "$CONFIG_DIR/ghostty"
ln -sfn "$REPO_DIR/.config/alacritty" "$CONFIG_DIR/alacritty"

# OS-Specific Configs
if [[ "$(uname)" == "Darwin" ]]; then
  echo "==> macOS detected: Linking Karabiner..."
  ln -sfn "$REPO_DIR/.config/karabiner" "$CONFIG_DIR/karabiner"
fi

echo "==> Done! All configs linked cleanly."
```

---

## 3. Platform Prerequisites & Installation Commands

### A. macOS (Homebrew)
```bash
# Install Homebrew package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Core tools
brew install neovim tmux fzf ripgrep fd zsh-autosuggestions zsh-syntax-highlighting

# TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

---

### B. Linux (Ubuntu / Debian / Arch)

#### Ubuntu / Debian:
```bash
sudo apt update && sudo apt install -y zsh tmux ripgrep fd-find fzf git curl

# Install Neovim (Latest via PPA or appimage)
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update && sudo apt install -y neovim

# Set Zsh as default shell
chsh -s $(which zsh)

# TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### Arch Linux:
```bash
sudo pacman -Syu zsh tmux neovim ripgrep fd fzf git
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

---

### C. Windows (WSL2 / Windows Terminal)

For Windows machines, **WSL2 (Ubuntu)** with **Windows Terminal** is recommended.

1. **Install WSL2**:
   Open PowerShell as Administrator:
   ```powershell
   wsl --install
   ```
2. **Setup inside WSL2 (Ubuntu environment)**:
   Follow the **Linux (Ubuntu)** setup instructions above.
3. **Ghostty / Alacritty / Windows Terminal Configuration**:
   - Windows Terminal supports native JSON settings and UTF-8 Nerd Fonts (e.g. `FiraCode Nerd Font` or `JetBrainsMono Nerd Font`).
   - If using **Alacritty** on Windows native host, point the config path in `%APPDATA%\alacritty\alacritty.yml` or symlink from Git workspace.

---

## 4. Key Neovim & Tmux Features Preserved

- **Neovim Markdown Auto-Wrap**: In `lua/polish.lua`, line wrapping, word breaks, and break indentation automatically activate for Markdown files (`wrap = true`, `linebreak = true`).
- **Tmux Seamless Navigation**: `Ctrl + h/j/k/l` seamlessly navigates between tmux panes and Neovim split windows via `vim-tmux-navigator`.
- **Fuzzy Finders**: `fzf` integration bound for session switching, window switching, URL selection, and file path copying.

---

## 5. Maintenance & Syncing

When making changes on any machine:
1. Edit files directly in `~/.config/nvim/`, `~/.tmux.conf`, etc. (they point to your git repo).
2. Commit and push:
   ```bash
   git add .
   git commit -m "feat(config): update terminal preferences"
   git push
   ```
3. On another machine:
   ```bash
   git pull
   tmux source-file ~/.tmux.conf   # Reload tmux
   ```
