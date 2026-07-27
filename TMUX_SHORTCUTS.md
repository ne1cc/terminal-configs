# TMUX Keyboard Shortcuts Reference

> **Configuration Status:** Custom bindings active with prefix `Ctrl+Space` (`C-Space`).
> Default keys that don't conflict with custom overrides remain fully active.

---

## 1. Custom Keybindings (from `.tmux.conf`)

These bindings have been custom-configured or overridden for ergonomics, Tokyo Night visual aesthetics, and specific developer workflows.

### Splitting & Navigation

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + \|` | Split pane vertically (left/right split, inherits directory) | Active Window |
| `Prefix + -` | Split pane horizontally (top/bottom split, inherits directory) | Active Window |
| `Prefix + h` | Focus pane to the **left** (Vim-style `h`) | Active Window |
| `Prefix + j` | Focus pane **down** (Vim-style `j`) | Active Window |
| `Prefix + k` | Focus pane **up** (Vim-style `k`) | Active Window |
| `Prefix + l` | Focus pane to the **right** (Vim-style `l`) | Active Window |
| `Ctrl + Tab` | Cycle focus to the next pane (no prefix needed) | Active Window |
| `Ctrl + Shift + Tab` | Cycle focus to the previous pane (no prefix needed) | Active Window |
| `Prefix + z` | Toggle zoom (maximize/minimize active pane) | Active Window |
| `Prefix + \`` | Toggle focus to the **last active window** (fast bounce) | Active Session |
| `Prefix + b` | Toggle tmux **status bar visibility** (fullscreen space) | Active Session |

### Pane Management & Reordering

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + ← / ↓ / ↑ / →` | Physically swap/move current pane in specified direction | Active Window |
| `Prefix + H / J / K / L` | Resize pane by 5 cells in direction (repeatable key) | Active Window |
| `Prefix + M` | **Join marked pane horizontally** (horizontal split) | Active Window |
| `Prefix + g` | Join pane — choose source interactively from tree view | Active Window |
| `Prefix + S` | Join pane — prompt for a source window number | Active Window |
| `Prefix + R` | Rename current pane title | Active Pane |
| `Prefix + x` | Kill active pane immediately (no confirmation prompt) | Active Window |
| `Prefix + G` | Kill all other panes in current window except the active one | Active Window |
| `Prefix + y` | **Toggle pane synchronization** (parallel keystrokes) | Active Window |
| `Prefix + <` | Move active pane to the **previous window** | Active Session |
| `Prefix + >` | Move active pane to the **next window** | Active Session |
| `Prefix + B` | **Toggle pane borders visibility** (status bar toggle) | Active Window |

### Windows & Sessions

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + c` | Create a new window (inherits active directory) | Active Session |
| `Prefix + X` | Kill active window immediately (no confirmation prompt) | Active Session |
| `Prefix + N` | Create a new named session (prompts for name) | Tmux Server |
| `Prefix + $` | Rename current session (prompts for name) | Active Session |
| `Prefix + S` | **Save tmux session state** (tmux-resurrect) + display toast | Active Session |
| `Prefix + R` | **Restore tmux session state** (tmux-resurrect) + display toast | Active Session |
| `Prefix + D` | Detach all other clients connected to the current session | Active Session |
| `Prefix + W` | Open high-information interactive tree (process, PID, activity) | Tmux Server |
| `Prefix + r` | **Reload `.tmux.conf` configuration file** + display toast | Tmux Server |

### Copy Mode (vi-mode)

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + Enter` | Quickly enter copy-mode (alternative to `Prefix + [`) | Active Pane |
| `v` | Begin text selection (in copy-mode) | Copy Mode |
| `Ctrl + v` | Toggle block/rectangle selection (in copy-mode) | Copy Mode |
| `y` | Yank selection to system clipboard + display status toast | Copy Mode |
| `Mouse Drag Release` | Select text and auto-copy to system clipboard + status toast | Copy Mode |
| `Escape` | Cancel selection / exit copy-mode | Copy Mode |

### Git Worktree & AI Workflows

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + Ctrl + n` | Create git worktree branch (prompt), open window running Claude | Active Session |
| `Prefix + Ctrl + a` | FZF-pick existing worktree in popup, open window running Claude | Active Session |
| `Prefix + Ctrl + x` | FZF-pick worktree in popup to force-remove (directory + branch) | Active Session |
| `Prefix + Ctrl + g` | Centered floating **git status popup** (Enter to dismiss) | Active Pane |
| `Prefix + a` | **Open/re-attach to persistent Claude popup session** | Active Session |
| `Prefix + A` | **Open side-by-side Claude pane** (35% width vertical split) | Active Session |
| `Prefix + f` | **Fuzzy Project Switcher** (popup modal to search git repos & switch sessions) | Active Session |

### Advanced Logging & Archiving

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + P` | Dump last 30,000 lines of pane scrollback history to `~/tmux_archive_*.log` | Active Pane |
| `Prefix + Alt + l` | Toggle continuous live-logging of active pane to `~/tmux-logs/` | Active Pane |
| `Prefix + Alt + p` | Save a static screenshot of current visible pane to `~/tmux-logs/` | Active Pane |
| `Prefix + Alt + P` | Save complete pane scrollback history to `~/tmux-logs/` | Active Pane |
| `Prefix + Alt + c` | Clear scrollback history of the active pane | Active Pane |

---

## 2. Active Default Keybindings (Unmodified)

These are native Tmux features that remain active because they are not overridden in `.tmux.conf`.

### Windows

| Keybinding | Action |
|---|---|
| `Prefix + ,` | Rename current window |
| `Prefix + n` | Move to next window |
| `Prefix + p` | Move to previous window |
| `Prefix + 1`–`9` | Select window by index number (1-based on your configuration) |
| `Prefix + f` | Find window by typing search text (matches titles/contents) |
| `Prefix + .` | Move current window (prompts for new index location) |
| `Prefix + '` | Select window by prompting for index number |

### Panes

| Keybinding | Action |
|---|---|
| `Prefix + m` | **Mark active pane** (crucial for `Prefix + M` marked-join workflow) |
| `Prefix + ;` | Switch focus back to the last active pane (great for fast toggling) |
| `Prefix + o` | Cycle focus to the next pane (by pane index) |
| `Prefix + q` | Briefly overlay pane index numbers on top of each pane |
| `Prefix + t` | Display a large digital clock (press any key to dismiss) |
| `Prefix + {` | Swap the current pane with the previous pane in index order |
| `Prefix + }` | Swap the current pane with the next pane in index order |
| `Prefix + Ctrl + o` | Rotate all panes in current window forward |
| `Prefix + Alt + o` | Rotate all panes in current window backward |
| `Prefix + !` | Break active pane out of current window into a new separate window |
| `Prefix + Space` | Cycle layout through presets (even-horizontal, even-vertical, tiled, etc.) |

### Sessions & Client Management

| Keybinding | Action |
|---|---|
| `Prefix + s` | Open interactive list of all active sessions |
| `Prefix + d` | Detach the current client (leaves session running in background) |
| `Prefix + L` | Switch to the last active session/client |

### Paste Buffers

| Keybinding | Action |
|---|---|
| `Prefix + ]` | Paste contents of the latest buffer |
| `Prefix + =` | List all copied buffers and select one to paste |

### Miscellaneous Command Keys

| Keybinding | Action |
|---|---|
| `Prefix + :` | Open tmux command line prompt |
| `Prefix + ?` | List all current active keybindings (built-in help menu) |
| `Prefix + i` | Display status information about current window/pane |
| `Prefix + ~` | Show tmux log messages (useful for troubleshooting) |
| `Prefix + PageUp` | Immediately enter copy-mode and scroll up one page |
