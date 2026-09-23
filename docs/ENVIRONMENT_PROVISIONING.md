# 1:1 High-Fidelity Environment Provisioning Guide

A comprehensive, zero-drift guide to provisioning and replicating the exact terminal environment, tools, multiplexer, AI skills, and development workflows across **macOS (Apple Silicon & Intel)**, **Linux (Ubuntu/Debian)**, and **Windows (WSL2)**.

---

## 1. Architectural Overview & Single Source of Truth

Every workstation is provisioned to mirror an identical 1:1 layout with zero configuration drift:

```text
~/
├── .zshrc, .zprofile, .p10k.zsh      # Shell configuration & Powerlevel10k theme
├── .tmux.conf, .tmux/plugins/tpm/    # Terminal multiplexer & auto-installed TPM plugins
├── .gitconfig, .taskrc, .inputrc     # Git (rerere enabled), Taskwarrior, and Readline
├── bin/                              # Symlinked CLI binaries (wma, sesh-picker, agyy, etc.)
├── .config/
│   ├── nvim/                         # AstroNvim IDE with Lazy plugins & AI integrations
│   ├── ghostty/, alacritty/          # GPU-accelerated terminal configurations
│   ├── lazygit/, yazi/               # Git TUI and terminal file manager
│   ├── sesh/, workmux/, fleet/       # Session manager, git worktree manager, orchestration
│   ├── glow/, starship.toml          # Markdown viewer and cross-shell prompt
│   └── karabiner/                    # Keyboard remapping (macOS only)
├── .claude/
│   ├── CLAUDE.md                     # Global Claude Code standards & memory
│   ├── commands/                     # Global slash commands (/plan, /cook, /continue, /release)
│   └── skills/                       # Shared AI skills
├── .gemini/config/                   # Antigravity CLI skills, rules, & lifecycle hooks
├── .codex/, .qoder/, .opencode/      # Codex, Qoder, and OpenCode instruction files & skills
└── Github/
    ├── ne1cc/                        # Canonical Git clones (mirrors github.com/ne1cc/*)
    ├── _tools/                       # Workflow utilities symlinked from terminal-configs/bin
    ├── workspace/                    # Sandboxes, local projects, and datasets
    ├── explore/                      # Third-party read-only reference clones
    └── archive/                      # Cold storage with MANIFEST.md index
```

---

## 2. Fresh Machine Bootstrap Matrix

| Platform | Primary Bootstrap Command | Underlying Scripts Executed |
|---|---|---|
| **macOS** (M1/M2/M3/Intel) | `bash bin/mac-bootstrap.sh` | Homebrew, `Brewfile`, Oh My Zsh, P10k, Stow, `link-agent-skills.sh`, `setup-github-workspace` |
| **Linux** (Ubuntu/Debian) | `bash bin/linux-bootstrap.sh` | `apt`, Linuxbrew, `Brewfile.linux`, Nerd Fonts, OMZ, P10k, Stow, `setup-github-workspace` |
| **Windows** (WSL2) | `bash bin/wsl-bootstrap.sh` | Linux bootstrap + `/etc/wsl.conf` interop, Windows clipboard (`clip.exe`), Nerd Font sync |
| **Portable Fallback (All)** | `./setup.sh --install-packages` | Idempotent symlinker with automatic collision backups, package bundle, TPM, and Lazy sync |

---

## 3. Step-by-Step Provisioning Walkthrough

### Step 1: Clone into the Canonical Path
On any fresh machine, clone the repository directly into its designated owner namespace:
```bash
mkdir -p ~/Github/ne1cc
git clone https://github.com/ne1cc/terminal-configs.git ~/Github/ne1cc/terminal-configs
cd ~/Github/ne1cc/terminal-configs
```

### Step 2: Run the Platform Bootstrap Script

#### A. macOS:
```bash
bash bin/mac-bootstrap.sh
```
*Prompted for Brewfile installation:* Enter `y` to install all GUI casks, CLI formulas, and fonts.

#### B. Linux (Ubuntu / Debian):
```bash
bash bin/linux-bootstrap.sh
```
*Prompted for Brewfile.linux installation:* Enter `y` to install all Linuxbrew CLI packages.

#### C. Windows Subsystem for Linux (WSL2):
```bash
bash bin/wsl-bootstrap.sh
```
*Configures Windows interop, copies fonts to Windows side, and sets up `wslview`.*

---

## 4. What Gets Automated During Provisioning

Running `./setup.sh` (or any bootstrap script) automatically enforces:

1. **Backup of Existing Files**:
   Conflicting files/symlinks are moved to `~/.terminal-configs-backups/<timestamp>` before replacement.
2. **Symlinks Established**:
   - Dotfiles: `.zshrc`, `.zprofile`, `.p10k.zsh`, `.tmux.conf`, `.gitconfig`, `.taskrc`, `.inputrc`, `.bashrc`, `.bash_profile`.
   - Tool directories in `~/.config/`: `nvim`, `ghostty`, `alacritty`, `lazygit`, `yazi`, `starship.toml`, `glow`, `fleet`, `sesh`, `workmux`, `karabiner`.
   - Global binaries: `terminal-configs/bin/*` linked to `~/bin/*`.
3. **Multi-Agent AI Skills & Standards**:
   - Executes `bin/link-agent-skills.sh`: links `.gemini/skills` to Gemini, Claude Code (`~/.claude/skills`), Codex (`~/.codex/skills`), Qoder (`~/.qoder/skills`), and OpenCode (`~/.config/opencode/skills`).
   - Links global instructions: `GEMINI.md`, `AGENTS.md`, and `QODER.md`.
   - Configures `workmux` status tracking hooks in `~/.gemini/config/hooks.json`.
4. **Claude Code Configuration**:
   - Executes `bin/link-claude-code.sh`: links `claude-code/CLAUDE.md` and global slash commands in `claude-code/commands/` (`/plan`, `/cook`, `/continue`, `/release`).
5. **Git Rerere Auto-Resolution**:
   - Enables `rerere.enabled = true` and `rerere.autoupdate = true` globally for automated conflict replay across worktrees and rebases.
6. **Multiplexer & TPM Plugins**:
   - Clones Tmux Plugin Manager (`tpm`) if absent.
   - Runs `~/.tmux/plugins/tpm/bin/install_plugins` to install `tmux-resurrect`, `tmux-continuum`, `tmux-fzf`, `tmux-yank`, etc.
7. **Neovim Plugin Sync**:
   - Runs `nvim --headless '+Lazy! sync' +qa` to pre-download and compile all plugins.
8. **GitHub Workspace Scaffolding**:
   - Executes `bin/setup-github-workspace --rename`: generates `~/Github/{ne1cc, config, explore, workspace, archive, tracking, _tools}`.

---

## 5. Post-Provisioning Verification Checklist

Run these quick checks on the newly provisioned workstation:

```bash
# 1. Reload shell
source ~/.zshrc

# 2. Verify Homebrew / Linuxbrew & core CLI tools
which eza bat zoxide fzf lazygit yazi sesh workmux wma

# 3. Verify tmux & status line
tmux new-session -d -s test-verify
tmux list-windows -t test-verify
tmux kill-session -t test-verify

# 4. Verify headless worktree workflow
mkdir -p /tmp/test-wt && cd /tmp/test-wt && git init -b main && git commit --allow-empty -m "init"
wma test-branch
workmux list
workmux remove test-branch
cd ~ && rm -rf /tmp/test-wt

# 5. Verify agent skills linking
ls -la ~/.gemini/config/skills ~/.claude/skills ~/.agents/skills
```

---

## 6. Keeping Workstations Synchronized (Drift Prevention)

When updates or modifications are made on one workstation, propagate them to others seamlessly:

```bash
# Pull latest changes on any machine
cd ~/Github/ne1cc/terminal-configs
git pull

# Run the idempotent setup installer
./setup.sh

# If new Homebrew packages or formulas were added:
./setup.sh --install-packages

# Reload shell configuration
source ~/.zshrc
```
