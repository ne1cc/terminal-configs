# Terminal Configs — Documentation Hub

Getting-started guides and workflow references for everything in `terminal-configs`.

**Quick load aliases:** `source ~/.zshrc`  
**Canonical repo path:** `~/Github/ne1cc/terminal-configs`

---

## Start here

| If you want to… | Read this |
|-----------------|-----------|
| Set up a fresh Mac, Linux, or WSL machine | [GITHUB_WORKSPACE_SETUP.md](GITHUB_WORKSPACE_SETUP.md) |
| Use `ghsync`, `ghn`, `ghr`, and GitHub aliases | [GITHUB_ALIASES_GUIDE.md](GITHUB_ALIASES_GUIDE.md) |
| Learn tmux layouts, AI panes, stashing, sessionizer | [TMUX_WORKFLOW_GUIDE.md](TMUX_WORKFLOW_GUIDE.md) |
| Git power moves, FZF, clipboard, ports, worktrees | [ZSH_GIT_WORKFLOW_GUIDE.md](ZSH_GIT_WORKFLOW_GUIDE.md) |
| Claude Code, Antigravity, agent matrix, handoffs | [AI_WORKFLOW_GUIDE.md](AI_WORKFLOW_GUIDE.md) |

---

## All guides

### Setup & workspace

| Guide | What it covers |
|-------|----------------|
| [ENVIRONMENT_PROVISIONING.md](ENVIRONMENT_PROVISIONING.md) | 1:1 High-fidelity provisioning across macOS, Linux, WSL2, zero drift |
| [GITHUB_WORKSPACE_SETUP.md](GITHUB_WORKSPACE_SETUP.md) | Bootstrap macOS/Linux/WSL, `~/Github` layout, verify setup |
| [GITHUB_ALIASES_GUIDE.md](GITHUB_ALIASES_GUIDE.md) | `ghsync`, `ghsync-pull`, `ghar`, `ghpin`, daily GitHub workflow |

### Terminal multiplexer & shell

| Guide | What it covers |
|-------|----------------|
| [TMUX_WORKFLOW_GUIDE.md](TMUX_WORKFLOW_GUIDE.md) | Prefix keys, workspaces, command palette, AI integration, persistence |
| [ZSH_GIT_WORKFLOW_GUIDE.md](ZSH_GIT_WORKFLOW_GUIDE.md) | Git aliases, worktrees, FZF tools, clipboard, ports, project bootstrapping |
| [MODERN_CLI_GUIDE.md](MODERN_CLI_GUIDE.md) | Eza, Bat, Zoxide, Delta, Direnv, modern replacements |

### Editors & tools

| Guide | What it covers |
|-------|----------------|
| [NEOVIM_GUIDE.md](NEOVIM_GUIDE.md) | Neovim overview, leader keys, integrations — links to deep dives |
| [TELESCOPE_GUIDE.md](TELESCOPE_GUIDE.md) | Snacks picker: find files, grep, git branches, buffers |
| [10X_NEOVIM_SESSION.md](10X_NEOVIM_SESSION.md) | Walkthrough: find code, trace bugs, edit fast |
| [LSP_SHORTCUTS.md](LSP_SHORTCUTS.md) | LSP navigation, diagnostics, rename, code actions |
| [LAZYGIT_GUIDE.md](LAZYGIT_GUIDE.md) | Lazygit TUI + AI custom commands (Claude, Antigravity, Codex) |
| [YAZI_GUIDE.md](YAZI_GUIDE.md) | Terminal file manager, preview tuning, openers |

### AI & automation

| Guide | What it covers |
|-------|----------------|
| [AI_WORKFLOW_GUIDE.md](AI_WORKFLOW_GUIDE.md) | Claude Code shell aliases, slash commands, Antigravity, handoffs |
| [claude-code/commands/README.md](../claude-code/commands/README.md) | `/plan`, `/cook`, `/continue`, `/release`, `/tech-dd` |

### Productivity & system

| Guide | What it covers |
|-------|----------------|
| [TASKWARRIOR_GUIDE.md](TASKWARRIOR_GUIDE.md) | Taskwarrior aliases, TUI, git hook integration |
| [TERMINAL_EMULATORS_GUIDE.md](TERMINAL_EMULATORS_GUIDE.md) | Ghostty, Alacritty, Karabiner-Elements |

---

## Quick reference (cheatsheets)

These are exhaustive lookup tables — use when you know *what* you need, not *how* to use it:

| Cheatsheet | Scope |
|------------|-------|
| [SHORTCUTS.md](../SHORTCUTS.md) | Master index: tmux, zsh, Neovim, Lazygit, Yazi, Karabiner |
| [TMUX_SHORTCUTS.md](../TMUX_SHORTCUTS.md) | Every tmux keybinding in table form |

---

## Daily workflow (recommended order)

```bash
# 1. Start terminal ? attaches to tmux session "main"
ta

# 2. Pull latest GitHub repos
ghsync-pull

# 3. Jump to a project
ghr olist-lakehouse
# or: Prefix + f  (tmux sessionizer)

# 4. Open editor layout
# Prefix + D  (dev workspace: editor + server + shell)

# 5. End of session — save handoff for AI resume
handoff "finished CI fixes"
# or: Prefix + Shift + H
```

---

## Script locations

All custom scripts live in `terminal-configs/bin/` and are symlinked to:

- `~/bin/`
- `~/Github/_tools/`

Run `install.sh` after `git pull` to refresh symlinks.

---

## Contributing docs

When adding a new workflow or alias:

1. Add the alias/script to `.zshrc` or `bin/`
2. Add a row to [SHORTCUTS.md](../SHORTCUTS.md)
3. If it's a multi-step workflow, add or update a guide in `docs/`
4. Link it from this README
