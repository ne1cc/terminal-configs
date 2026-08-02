# 🖥️ macOS Terminal Configs & Dotfiles

A premium, curated repository for my complete macOS terminal setup, shell environment, terminal multiplexer (tmux), GPU-accelerated terminal emulator (Ghostty), and Neovim development environment.

## 📦 What's Included

```
terminal-configs/
├── .config/
│   ├── ghostty/
│   │   └── config       # Ghostty custom keybindings & layout configuration
│   └── nvim/            # Complete Neovim config (AstroNvim-based)
├── .p10k.zsh            # Powerlevel10k prompt aesthetic settings
├── .tmux.conf           # tmux prefix binds, mouse scrolling, & pane joining utilities
├── .zshrc               # Shell aliases, custom audit logs, & OMZ initialization
├── Brewfile             # Homebrew package, cask, font, and extension manifest
└── setup.sh             # Portable, idempotent installer with conflict backups

```

---

## 🚀 Migration & Quick Start (New Mac)

Follow these steps to fully restore your environment on a fresh macOS installation.

### Step 1: Install Xcode Command Line Tools
Open Terminal and run:
```bash
xcode-select --install
```

### Step 2: Install Homebrew & Restore Packages
Install Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Once Homebrew is active, you can restore all apps, CLI tools, fonts, and VS Code extensions using the included [Brewfile](file:///Users/alex/terminal-configs/Brewfile):
```bash
brew bundle --file=~/terminal-configs/Brewfile
```
*(Alternatively, the `install.sh` script will prompt you to run this automatically).*


### Step 3: Install Oh My Zsh & Powerlevel10k
Install Oh My Zsh:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Clone the Powerlevel10k prompt theme:
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/Applications/powerlevel10k
```

### Step 4: Clone & Run the Portable Setup Script
Clone this repository to your new machine:
```bash
git clone <YOUR_REPOSITORY_URL> ~/terminal-configs
cd ~/terminal-configs
```

Link the configuration and install tmux/Neovim plugins:
```bash
./setup.sh
```
The script detects macOS, Linux, and WSL; moves conflicting files to
`~/.terminal-configs-backups/<timestamp>`; and establishes symlinks from the
repository folder to your home directory. To restore packages too, run:
```bash
./setup.sh --install-packages
```

---

## 🛠️ Configuration Details

### 🐚 Zsh (`.zshrc` & `.p10k.zsh`)
* Integrates **Powerlevel10k** and **Oh My Zsh**.
* Includes automated custom aliases and integrations for logging tasks/commits.
* Preconfigured tool chains like `delta` for side-by-side terminal diffs and `glow` for markdown rendering.

### 🗂️ Tmux (`.tmux.conf`)
* Remaps leader/prefix prefix key to `Ctrl+Space`.
* Full mouse support enabled (scrolling, selecting panes).
* Programmed mouse dragging to copy directly to the macOS system clipboard.
* Custom joins/swaps (`Prefix + j` / `Prefix + S`) to reorganize workspace tiles easily.
* High-information pane/window debugging views (`Prefix + W`).

### ⚡ Ghostty (`.config/ghostty/config`)
* GPU-accelerated terminal.
* Configures tab navigation with native system shortcuts (`Cmd+Shift+]` / `Cmd+Shift+[`).
* Unbinds default conflicting keys to pass Ctrl+Tab and Ctrl+Shift+Tab cleanly to tmux.

### ✍️ Neovim (`.config/nvim`)
* Customized AstroNvim structure.
* Extensible Lua plugins, including `mason.lua` (LSP/DAP manager), `harpoon.lua` (quick file switching), and `none-ls.lua` (formatting/linting).
