# Comprehensive Terminal Environment Shortcuts Guide

A complete, organized, and sequential reference for all configured keyboard shortcuts across **tmux**, **Neovim**, **Lazygit**, **zsh**, **Ghostty**, **Alacritty**, and **Karabiner-Elements**.

---

## 1. tmux Keybindings (Prefix: `Ctrl + Space`)

All tmux shortcuts require pressing the prefix `Ctrl + Space` first, unless designated as **(No Prefix)**.

### A. Navigation & Seamless Vim Integration
| Keybinding | Scope | Description |
|---|---|---|
| `Ctrl + h` | **(No Prefix)** | Focus pane / split to the left (passes through to Neovim) |
| `Ctrl + j` | **(No Prefix)** | Focus pane / split down (passes through to Neovim) |
| `Ctrl + k` | **(No Prefix)** | Focus pane / split up (passes through to Neovim) |
| `Ctrl + l` | **(No Prefix)** | Focus pane / split to the right (passes through to Neovim) |
| `Ctrl + \` | **(No Prefix)** | Jump to last-focused pane/split (passes through to Neovim) |
| `Ctrl + Tab` | **(No Prefix)** | Cycle to next pane |
| `Ctrl + Shift + Tab` | **(No Prefix)** | Cycle to previous pane |
| `Shift + Left Arrow` | **(No Prefix)** | Switch to previous tmux window |
| `Shift + Right Arrow` | **(No Prefix)** | Switch to next tmux window |
| `Prefix + \`` | Prefix | Jump to last active window |

### B. Splitting & Window Layout
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + \|` | Prefix | Split window vertically (inherits working directory) |
| `Prefix + -` | Prefix | Split window horizontally (inherits working directory) |
| `Prefix + c` | Prefix | Create new window (inherits working directory) |
| `Prefix + v` | Prefix | **Smart Split**: horizontal if wide screen, vertical if tall |
| `Prefix + z` | Prefix | **Toggle Pane Zoom** (maximize/restore active pane) |
| `Prefix + b` | Prefix | Toggle tmux top status bar visibility |
| `Prefix + Ctrl-b` | Prefix | Toggle pane border status headers |

### C. Pane Management & Resizing
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Shift + H` | Prefix | Resize pane 5 cells left (repeatable) |
| `Prefix + Shift + J` | Prefix | Resize pane 5 cells down (repeatable) |
| `Prefix + Shift + K` | Prefix | Resize pane 5 cells up (repeatable) |
| `Prefix + Shift + L` | Prefix | Resize pane 5 cells right (repeatable) |
| `Prefix + Left Arrow` | Prefix | Swap/move active pane to the left |
| `Prefix + Down Arrow` | Prefix | Swap/move active pane down |
| `Prefix + Up Arrow` | Prefix | Swap/move active pane up |
| `Prefix + Right Arrow` | Prefix | Swap/move active pane to the right |
| `Prefix + x` | Prefix | Kill active pane (no confirmation prompt) |
| `Prefix + Shift + X` | Prefix | Kill active window (no confirmation prompt) |
| `Prefix + Shift + G` | Prefix | **Kill all other panes** in the window except active pane |
| `Prefix + m` | Prefix | Mark current pane |
| `Prefix + Shift + M` | Prefix | Join marked pane horizontally into current window |
| `Prefix + g` | Prefix | Interactively select pane from tree to join into window |
| `Prefix + Shift + S` | Prefix | Prompt for source window number to join pane |
| `Prefix + Shift + R` | Prefix | Rename current pane title |
| `Prefix + y` | Prefix | Toggle pane synchronization (send keys to all panes) |
| `Prefix + Shift + B` | Prefix | Break active pane out into its own new window |
| `Prefix + Alt + Shift + B` | Prefix | Break active pane into a **background window** (`M-B`) |
| `Prefix + Alt + b` | Prefix | Promote all other panes in window to background windows (`M-b`) |
| `Prefix + Alt + j` | Prefix | Pull all panes from another window into this one (`M-j`) |
| `Prefix + Alt + m` | Prefix | Push all panes from this window to another window (`M-m`) |
| `Prefix + >` / `Prefix + <` | Prefix | Move active pane to next / previous window |
| `Ctrl + Shift + Left Arrow` | **(No Prefix)** | Swap window position left in tab bar |
| `Ctrl + Shift + Right Arrow` | **(No Prefix)** | Swap window position right in tab bar |

### D. Interactive Pickers & Popups
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + s` | Prefix | **Fuzzy Session Switcher** (fzf popup modal) |
| `Prefix + w` | Prefix | **Fuzzy Window Switcher** (fzf popup modal) |
| `Prefix + Shift + W` | Prefix | Detailed process tree (PID, memory, last activity) |
| `Prefix + f` | Prefix | **Tmux Sessionizer**: fuzzy find git project & launch session |
| `Prefix + Ctrl + g` | Prefix | **Centered Lazygit Floating Popup** (90% screen width) |
| `Prefix + Shift + F` | Prefix | Fuzzy find file path & copy relative path to clipboard |
| `Prefix + Shift + N` | Prefix | Prompt to create new named session |
| `Prefix + $` | Prefix | Rename current session |
| `Prefix + Shift + D` | Prefix | Detach all other attached clients |
| `Prefix + r` | Prefix | Reload `~/.tmux.conf` configuration |

### E. Window Stashing (Background Sessions)
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Alt + s` | Prefix | **Stash Window**: move window to background `stash` session (`M-s`) |
| `Prefix + Alt + r` | Prefix | **Retrieve Window**: fuzzy-pick stashed window and restore (`M-r`) |

### F. Git Worktrees & AI Claude Integration
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Ctrl + n` | Prefix | Prompt branch name, create git worktree & open Claude window |
| `Prefix + Ctrl + a` | Prefix | Fuzzy-pick existing worktree and open Claude window |
| `Prefix + Ctrl + x` | Prefix | Fuzzy-pick worktree to force-remove (dir + branch) |
| `Prefix + a` | Prefix | Open/reattach persistent centered Claude popup session |
| `Prefix + Ctrl + p` | Prefix | Open/reattach project-specific Claude popup session |
| `Prefix + Shift + A` | Prefix | Open side-by-side Claude pane (35% width split) |
| `Prefix + Ctrl + c` | Prefix | Spawn new full window running Claude in CWD |

### G. Logging & State Persistence
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Shift + P` | Prefix | Dump 30,000 lines of scrollback to `~/tmux_archive_*.log` |
| `Prefix + Alt + l` | Prefix | Toggle continuous pane output logging to `~/tmux-logs/` |
| `Prefix + Alt + p` | Prefix | Take text screenshot of visible pane to `~/tmux-logs/` |
| `Prefix + Alt + Shift + P` | Prefix | Save complete scrollback buffer to `~/tmux-logs/` |
| `Prefix + Alt + c` | Prefix | Clear pane scrollback history |
| `Prefix + Ctrl + s` | Prefix | Manually save session layout state via `tmux-resurrect` |
| `Prefix + Ctrl + r` | Prefix | Manually restore session layout state via `tmux-resurrect` |
| `Prefix + Shift + I` | Prefix | Install newly declared TPM plugins |
| `Prefix + Shift + U` | Prefix | Update installed TPM plugins |
| `Prefix + Alt + u` | Prefix | Clean unused TPM plugins |

---

## 2. Neovim Keybindings (Leader: `Space`)

### A. Navigation & Windows
| Keybinding | Description |
|---|---|
| `Ctrl + h` | Move to left split / tmux pane |
| `Ctrl + j` | Move to down split / tmux pane |
| `Ctrl + k` | Move to up split / tmux pane |
| `Ctrl + l` | Move to right split / tmux pane |
| `Ctrl + \` | Jump to previous split / tmux pane |
| `<leader>e` | Toggle Neo-tree filesystem sidebar |
| `<leader>o` | Toggle focus between Neo-tree sidebar and editor buffer |
| `]b` / `[b` | Cycle next / previous buffer tab |
| `<leader>bd` | Close current buffer tab |

### B. Git & Lazygit Integration
| Keybinding | Description |
|---|---|
| `<leader><C-g>` | **Toggle Floating Lazygit TUI** (`lazygit.nvim`) |
| `<leader>gg` | **Toggle Floating Lazygit TUI** (`lazygit.nvim`) |
| `<leader>tl` | **Toggle Floating Lazygit TUI** (`lazygit.nvim`) |
| `<leader>gS` | Open Fugitive git status window (`:Git`) |
| `<leader>gD` | Open Fugitive git diff window (`:Git diff`) |
| `<leader>gB` | Open Fugitive git blame window (`:Git blame`) |
| `<leader>gP` | Run Fugitive git push (`:Git push`) |

---

## 3. Lazygit Custom Commands & Keybindings

Inside Lazygit (`Prefix + Ctrl + g` or `lg` in terminal):

| Key | Context | Action / Tool Executed | Description |
|---|---|---|---|
| **`a`** | `files` | **Antigravity (`agy`)** | Generates conventional commit message from staged changes |
| **`C`** | `files` | **Claude CLI (`claude`)** | Passes staged diff to Claude for bug/performance review |
| **`X`** | `localBranches` | **OpenAI Codex (`codex`)** | Analyzes branch changes to explain architectural impact |
| **`Q`** | `files` | **Qoder (`qodercli`)** | Passes staged diff into `qodercli` for automated code audit |
| **`N`** | `global` | **GitHub CLI (`gh`)** | Creates GitHub Pull Request (`gh pr create --fill`) |
| **`O`** | `localBranches` | **GitHub CLI (`gh`)** | Checks out GitHub PR for selected branch (`gh pr checkout`) |
| **`q`** | Global | Close Lazygit | Exit TUI and return to tmux / shell |

---

## 4. Terminal Emulators & OS Shortcuts

### A. Ghostty
| Keybinding | Action |
|---|---|
| `Cmd + d` | Split terminal pane right |
| `Cmd + Shift + d` | Split terminal pane down |
| `Cmd + h` / `Cmd + l` | Focus terminal split left / right |
| `Cmd + k` / `Cmd + j` | Focus terminal split top / bottom |
| `Ctrl + Tab` | Sent as `C-Tab` (`\x1b[27;5;9~`) to cycle tmux panes |
| `Ctrl + Shift + Tab` | Sent as `C-BTab` (`\x1b[27;6;9~`) to cycle tmux panes |

### B. Karabiner-Elements (macOS)
| Keybinding | Action |
|---|---|
| `Cmd + Option + h` | Cycle application window backward (`Cmd + Shift + \``) |
| `Cmd + Option + l` | Cycle application window forward (`Cmd + \``) |

### C. Zsh Shell Aliases & Functions
| Command | Action |
|---|---|
| `lg` | Launch Lazygit TUI in full terminal |
| `ta` | Attach to `main` tmux session or create it if missing |
| `tl` | List active tmux sessions |
| `tk <name>` | Kill named tmux session |
| `tmux-stash` | Move current window to background `stash` session |
| `tmux-unstash` | Fuzzy-pick window out of `stash` and restore |
| `snap` | Take screenshot to `~/Pictures/Screenshots` & copy to clipboard |
| `agy` | Execute Antigravity CLI prompt |
| `agya` | Export and preview latest Antigravity session audit report |
