# 🖥️ macOS / Linux Terminal Configs & Dotfiles

A premium, curated repository for my complete terminal environment, shell configuration, terminal multiplexer (tmux), GPU-accelerated terminal emulators (Ghostty & Alacritty), file manager (Yazi), Git TUI (Lazygit), and Neovim development environment.

---

## 📖 Master Guides & Documentation
* 🚀 **[Master Cheatsheet](file:///Users/alex/Github/config/terminal-configs/SHORTCUTS.md)** — Complete, exhaustive keybinding and alias reference.
* 🗂️ **[tmux Shortcuts & Layouts](file:///Users/alex/Github/config/terminal-configs/TMUX_SHORTCUTS.md)** — Window stashing, pane joining, breakout sessions.
* ⚡ **[Modern CLI Guide](file:///Users/alex/Github/config/terminal-configs/MODERN_CLI_GUIDE.md)** — Eza, Bat, Zoxide, FZF, Ripgrep, Duf, Dust.
* ✍️ **[10X Neovim Session Guide](file:///Users/alex/Github/config/terminal-configs/docs/10X_NEOVIM_SESSION.md)** — Neovim workflows, buffer management, and image integration.
* 🩺 **[LSP Shortcuts](file:///Users/alex/Github/config/terminal-configs/docs/LSP_SHORTCUTS.md)** — Code navigation, diagnostics, and formatting.
* ✅ **[Taskwarrior Guide](file:///Users/alex/Github/config/terminal-configs/docs/TASKWARRIOR_GUIDE.md)** — Terminal task tracking workflows.

---

## 📦 What's Included

```
terminal-configs/
├── .config/
│   ├── alacritty/       # Alacritty config (Tokyo Night, vibrancy & tmux integration)
│   ├── ghostty/         # Ghostty GPU terminal configuration & keybinds
│   ├── karabiner/       # Karabiner-Elements keyboard custom modifications
│   ├── lazygit/         # Lazygit config with AI (Antigravity/Claude/Codex) workflows
│   ├── nvim/            # Complete Neovim environment (AstroNvim-based)
│   ├── yazi/            # Yazi terminal file manager config & plugins
│   └── starship.toml    # Cross-shell Starship prompt configuration
├── bin/                 # Custom CLI binaries (tmux-sessionizer, snapshot utilities)
├── claude-code/
│   ├── CLAUDE.md        # Unified global instructions (merged MSTSPAT standards)
│   └── commands/        # Custom slash commands (/plan, /cook, /continue, /release)
├── docs/                # Specialized workflow and shortcut guides
├── .inputrc             # GNU Readline keybindings
├── .p10k.zsh            # Powerlevel10k prompt settings
├── .tmux.conf           # tmux prefix binds, mouse copy, popups, & stashing
├── .zshrc               # Shell aliases, git power moves, & developer utilities
├── Brewfile             # macOS Homebrew packages, casks, and fonts
├── Brewfile.linux       # Linuxbrew package manifest
├── SHORTCUTS.md         # Exhaustive master keyboard & alias reference
├── setup.sh             # Portable, idempotent symlink installer
└── install.sh           # Interactive bootstrap script
```

---

## 🚀 Migration & Quick Start

Follow these steps to fully restore your environment on a fresh machine.

### Step 1: Install Homebrew / Linuxbrew & Restore Packages
On macOS:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file=~/Github/config/terminal-configs/Brewfile
```

### Step 2: Run the Portable Setup Script
```bash
./setup.sh
```
The script detects macOS, Linux, and WSL; moves existing conflicting files to `~/.terminal-configs-backups/<timestamp>`; and establishes symlinks from the repository folder to your home directory.

To restore packages automatically as part of setup:
```bash
./setup.sh --install-packages
```

---

## 🛠️ Configuration Details

### 🐚 Zsh (`.zshrc` & `.p10k.zsh`)
* Integrates **Powerlevel10k** and **Oh My Zsh**.
* Includes developer workflow utilities: `groot`, `gwip`, `copylast`, `port`, `killport`, `serve`, `fkill`, `fo`.
* Antigravity AI audit ledger previewers (`glog`, `gdiff`, `agya`, `agyih`).

### 🗂️ Tmux (`.tmux.conf`)
* Remaps prefix key to `Ctrl + Space`.
* Seamless pane navigation with Neovim (`Ctrl + h/j/k/l`).
* Interactive fuzzy popups for sessionizer, windows, panes, and stashed scratchpads (`Prefix + s/w/e/f`).
* Floating Lazygit modal (`Prefix + Ctrl + g`) and Claude assistants.

### ✍️ Neovim (`.config/nvim`)
* Customized AstroNvim structure with Tokyo Night theme.
* Inline image rendering (`3rd/image.nvim` + `img-clip.nvim`), PDF viewing (`MuPDF`), and FzfLua picker.

### 🤖 Claude Code Workflows (Configuration as Code)
* Integrates a version-controlled global [CLAUDE.md](file:///Users/alex/Github/config/terminal-configs/claude-code/CLAUDE.md) symlinked automatically to `~/.claude/CLAUDE.md`.
* Custom global slash commands in [commands/](file:///Users/alex/Github/config/terminal-configs/claude-code/commands/) symlinked to `~/.claude/commands/` for use in any project:
  * `/plan` — Strategic Planning: Discovers requirements, mapping dependencies, and creating/updating the `TODO.md` roadmap.
  * `/cook` — Focused Implementation: Executes tasks from `TODO.md` in dependency order, enforcing code quality standards.
  * `/continue` — Intelligent Resumption: Inspects git status and `TODO.md` progress to resume work cleanly.
  * `/release` — Production Preparation: Orchestrates lints, formatting, test suites, builds, semantic versioning, and git tags/push.
* Enforces the **MSTSPAT** code quality standard: Minimal, Self-documenting, Type-exact, Secure, Performant, Accessible, and Testable code.
* Mandates structured architectural planning using `<thinking>` tags and strict execution validation checks.
