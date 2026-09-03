# TMUX Keyboard Shortcuts Reference

> **Configuration Status:** Custom bindings active with prefix `Ctrl+Space` (`C-Space`).
> Default keys that don't conflict with custom overrides remain fully active.

> **Workflow guide:** See **[docs/TMUX_WORKFLOW_GUIDE.md](docs/TMUX_WORKFLOW_GUIDE.md)** for layouts, command palette, AI integration, and daily patterns. This file is the full binding lookup table.

> **Last audited:** 2026-08-23 — no duplicate prefix bindings in `.tmux.conf`.

---

## 1. Custom Keybindings (from `.tmux.conf`)

These bindings have been custom-configured or overridden for ergonomics, Tokyo Night visual aesthetics, and specific developer workflows.

### Splitting & Navigation

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + \|` | Split pane vertically (left/right split, inherits directory) | Active Window |
| `Prefix + -` | Split pane horizontally (top/bottom split, inherits directory) | Active Window |
| `Prefix + v` | **Smart split** — horizontal if window is wide, vertical if tall | Active Window |
| `Prefix + h` | Focus pane to the **left** (Vim-style `h`) | Active Window |
| `Prefix + j` | Focus pane **down** (Vim-style `j`) | Active Window |
| `Prefix + k` | Focus pane **up** (Vim-style `k`) | Active Window |
| `Prefix + l` | Focus pane to the **right** (Vim-style `l`) | Active Window |
| `Ctrl + Tab` | Cycle focus to the next pane (no prefix needed) | Active Window |
| `Ctrl + Shift + Tab` | Cycle focus to the previous pane (no prefix needed) | Active Window |
| `Prefix + z` | Toggle zoom (maximize/minimize active pane) | Active Window |
| `Prefix + \`` | Toggle focus to the **last active window** (fast bounce) | Active Session |
| `Prefix + Tab` / `Prefix + Shift + Tab` | Same as `` ` `` — jump to last active window | Active Session |
| `Prefix + b` | Toggle tmux **status bar visibility** (fullscreen space) | Active Session |

### Window & Session Pickers (choose-tree & fzf popups)

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + s` | Fuzzy **session** switcher (`fzf` popup) | Tmux Server |
| `Prefix + w` | Interactive **tree/window picker** (`choose-tree -Zw`, collapsed panes) | Tmux Server |
| `Prefix + e` | Fuzzy **pane** switcher with **live scrollback preview** | Tmux Server |
| `Prefix + f` | Fuzzy **project/sessionizer** — search git repos & attach/switch | Tmux Server |
| `Prefix + /` | **Command Palette HUD** — fuzzy search & trigger any workflow | Active Window |

#### Tree Mode Navigation (inside `Prefix + w` / `choose-tree`)
* `h` — Collapse current tree item
* `l` — Expand current tree item
* `H` — Collapse all tree items
* `L` — Expand all tree items
* `Enter` — Select and switch to highlighted window or session
* `q` / `Esc` — Dismiss tree picker

### Pane Management & Reordering

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + ← / ↓ / ↑ / →` | Physically swap/move current pane in specified direction | Active Window |
| `Prefix + H / J / K / L` | Resize pane by 5 cells in direction (repeatable key) | Active Window |
| `Prefix + ,` | **Rename current window** (prompt) | Active Window |
| `Prefix + .` | **Rename current pane title** (prompt) | Active Pane |
| `Prefix + M` | **Join marked pane horizontally** (`Prefix + m` to mark first) | Active Window |
| `Prefix + g` | **Join panes** — fuzzy multi-select with live preview (`tmux-join-panes`) | Active Window |
| `Prefix + J` | Join pane — pick source from interactive tree | Active Window |
| `Prefix + Alt + Shift + S` | Join pane — prompt for source **window number** | Active Window |
| `Prefix + x` | Kill active pane immediately (no confirmation prompt) | Active Window |
| `Prefix + G` | Kill all **other** panes in current window (keep active) | Active Window |
| `Prefix + y` | **Toggle pane synchronization** (parallel keystrokes) | Active Window |
| `Prefix + <` | Move active pane to the **previous window** | Active Session |
| `Prefix + >` | Move active pane to the **next window** | Active Session |
| `Prefix + B` | **Break pane** out into its own window | Active Pane |
| `Prefix + Ctrl + b` | **Toggle pane border status** (show/hide per-pane titles) | Active Window |
| `Prefix + Alt + Shift + B` | Break active pane to a **background window** (`-d`) | Active Pane |
| `Prefix + Alt + b` | Break **all other panes** in window to background windows | Active Window |
| `Prefix + Alt + j` | **Pull all panes** from a specified window into current window | Active Window |
| `Prefix + Alt + m` | **Push all panes** from current window to another window | Active Window |
| `Prefix + Alt + w` / `Prefix + Ctrl + w` | Break current window into a **new named session** (in-place) | Active Window |
| `Prefix + Alt + p` | Break active pane into a **new named session** (in-place) | Active Pane |
| `Prefix + =` | **Tile / rebalance** panes evenly in current window | Active Window |

### Window Stashing

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + Alt + s` | **Stash** current window → background `stash` session (job keeps running) | Active Window |
| `Prefix + Alt + r` | **Unstash** — fuzzy pick a window from `stash` and restore it here | Active Session |

### Windows & Sessions

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + c` | Create a new window (inherits active directory) | Active Session |
| `Prefix + X` | Kill active window immediately (no confirmation prompt) | Active Session |
| `Prefix + N` | Create a new named session (prompts for name) | Tmux Server |
| `Prefix + $` | Rename current session (prompts for name) | Active Session |
| `Prefix + Shift + S` | **Save default tmux session state** (tmux-resurrect) + toast | Active Session |
| `Prefix + Shift + R` | **Restore default tmux session state** (tmux-resurrect) + toast | Active Session |
| `Prefix + Ctrl + s` | **Save custom named backup** (prompts for snapshot name, e.g. `pre-demo`) | Active Session |
| `Prefix + Ctrl + r` | **Restore from custom named backup** (interactive fzf picker popup) | Active Session |
| `Prefix + Alt + d` | Detach **all other clients** from the current session | Active Session |
| `Prefix + W` | Open high-information interactive tree (process, PID, activity) | Tmux Server |
| `Prefix + r` | **Reload `.tmux.conf`** + display toast | Tmux Server |
| `Prefix + Alt + a` | Break active pane → new session in **Alacritty** | Active Pane |
| `Prefix + Alt + g` | Break active pane → **new tmux session** → **new Ghostty window** (`tmux-breakout-ghostty`) | Active Pane |
| `Prefix + @` | Break current window → new session in new **Ghostty** window | Active Window |

### Copy Mode (vi-mode)

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + Enter` | Quickly enter copy-mode (alternative to `Prefix + [`) | Active Pane |
| `Prefix + u` | Enter copy-mode and scroll up half a page | Active Pane |
| `v` | Begin text selection (in copy-mode) | Copy Mode |
| `Ctrl + v` | Toggle block/rectangle selection (in copy-mode) | Copy Mode |
| `y` | Yank selection to system clipboard + display status toast | Copy Mode |
| `Shift + y` | Yank entire line to clipboard | Copy Mode |
| `f` | Extract URLs from pane → fzf picker → open in browser | Copy Mode |
| `i` | Exit copy-mode (return to normal mode) | Copy Mode |
| `Mouse Drag Release` | Select text and auto-copy to system clipboard + status toast | Copy Mode |
| `Escape` | Cancel selection / exit copy-mode | Copy Mode |

### Git Worktree & AI Workflows

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + Ctrl + n` | Create git worktree branch (prompt), open window running Claude | Active Session |
| `Prefix + Ctrl + a` | FZF-pick existing worktree in popup, open window running Claude | Active Session |
| `Prefix + Ctrl + x` | FZF-pick worktree in popup to force-remove (directory + branch) | Active Session |
| `Prefix + Ctrl + g` | Centered floating **lazygit popup frame** (q to dismiss) | Active Pane |
| `Prefix + a` | **Open/re-attach to persistent Claude popup session** | Active Session |
| `Prefix + Alt + y` | **Open/re-attach to persistent Antigravity YOLO popup session (`agyy`)** | Active Session |
| `Prefix + O` (`Shift + o`) | **Screen File & Stacktrace Jumper** (extract file paths on screen & jump in Neovim) | Active Window |
| `Prefix + Alt + i` | **Instant Floating Scratchpad** (quick notes in `~/notes/scratchpad.md`) | Active Window |
| `Prefix + A` | **Open side-by-side Claude pane** (35% width vertical split) | Active Session |
| `Prefix + Ctrl + c` | New window named "Claude" running Claude in current directory | Active Session |
| `Prefix + Ctrl + t` | **Agent Matrix Launcher** (interactive fzf modal for 2/3/4-pane AI grids) | Active Session |
| `Prefix + H` | **Session Handoff Snapshot** (dumps git status, diff stats, active tasks to markdown) | Active Session |
| `Prefix + F` | Fuzzy file picker → copy absolute path to clipboard | Active Pane |

### Power-User Workspaces & Telemetry Modals

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + Shift + D` | **Instant Dev Workspace Layout** (65% Neovim / 35% server & shell stack) | Active Window |
| `Prefix + Alt + Shift + D` | **Instant Triage Workspace Layout** (4-pane 2×2 grid for incident/bug analysis) | Active Window |
| `Prefix + Shift + T` | **Hardware & Process Telemetry Modal** (floating `btop`/`htop` overlay) | Active Window |
| `Prefix + Shift + K` | **Interactive Process Killer Modal** (floating `fkill` process picker) | Active Window |
| `Prefix + Ctrl + d` | **Interactive Docker Exec Modal** (fuzzy select container & drop into shell) | Active Window |
| `Prefix + Ctrl + h` | **Interactive SSH Host Jumper Modal** (fuzzy select SSH host & connect) | Active Window |
| `Prefix + Alt + k` | **Listening Ports & Dev Servers Inspector** | Active Window |
| `Prefix + Alt + c` | **Developer Cheatsheet & Docs HUD** (interactive query to `cheat.sh`) | Active Window |
| `Prefix + Alt + e` | **Dotfiles Config Switcher & Editor** (fuzzy edit `.tmux.conf`, `.zshrc`, `nvim`, etc.) | Active Window |
| `Prefix + Shift + Y` | **Capture full visible pane** to system clipboard with notification toast | Active Pane |

### Advanced Logging & Archiving

Every pane also **auto-logs** to `~/tmux-logs/` from creation (see hooks in `.tmux.conf`).

| Keybinding | Action | Context / Scope |
|---|---|---|
| `Prefix + Shift + P` | Dump last 30,000 lines of pane scrollback to `~/tmux_archive_*.log` | Active Pane |
| `Prefix + Alt + l` | Toggle continuous live-logging of active pane (`tmux-logging` plugin) | Active Pane |
| `Prefix + Alt + p` | Save a static screenshot of current visible pane to `~/tmux-logs/` | Active Pane |
| `Prefix + Alt + Shift + P` | Save complete pane scrollback history to `~/tmux-logs/` | Active Pane |

> **Note:** `Prefix + Alt + c` is bound to the cheatsheet HUD. Use the command palette (`Prefix + /`) or tmux command prompt for plugin logging utilities if needed.

---

## 2. Active Default Keybindings (Unmodified)

These are native Tmux features that remain active because they are not overridden in `.tmux.conf`.

### Overrides reminder

These **default** keys are replaced by custom bindings above — do not expect stock behavior:

| Default key | Stock action | Your override |
|---|---|---|
| `Prefix + f` | Find window by search text | Fuzzy project sessionizer |
| `Prefix + s` | Interactive session list | Fuzzy session switcher |
| `Prefix + w` | Interactive window list | Interactive tree/window picker (`choose-tree -Zw`) with vim folding (`h`/`l`/`H`/`L`) |
| `Prefix + e` | *(none by default)* | Fuzzy pane switcher with preview |
| `Prefix + .` | Move window to index | Rename pane title |
| `Prefix + =` | List paste buffers | Tile panes evenly |
| `Prefix + B` | *(none by default)* | Break pane to new window |
| `Prefix + S` / `Prefix + R` | *(none by default)* | Resurrect save / restore |

### Windows

| Keybinding | Action |
|---|---|
| `Prefix + c` | Create a new window (inherits active directory) |
| `Prefix + ,` | Rename current window |
| `Prefix + n` | Move to next window |
| `Prefix + p` | Move to previous window |
| `Prefix + 1`–`9` | Select window by index number (1-based on your configuration) |
| `Prefix + '` | Select window by prompting for index number |
| `Prefix + .` (stock) / `:move-window -t <n>` | Move / renumber current window to index |
| `Shift + Left` / `Shift + Right` | Previous / next window (no prefix) |
| `Ctrl + Shift + h` / `Ctrl + Shift + l` | Previous / next window (no prefix) |
| `Ctrl + PageUp` / `Ctrl + PageDown` | Previous / next window (no prefix) |
| `Ctrl + Shift + Left` / `Ctrl + Shift + Right` | Swap window order left/right (no prefix) |

### Panes

| Keybinding | Action |
|---|---|
| `Prefix + !` | **Break active pane** out of current window into a new window |
| `Prefix + Alt + Shift + B` | **Break active pane** into a **background window** (`break-pane -d`) |
| `Prefix + Alt + b` | **Demote all other panes** into background windows |
| `Prefix + Alt + p` | **Break active pane** into a **brand new session** (prompts for name) |
| `Prefix + Alt + w` / `Prefix + Ctrl + w` | **Break active window** into a **brand new session** (prompts for name) |
| `Prefix + <` / `Prefix + >` | Move active pane to previous / next window |
| `Prefix + m` | **Mark active pane** (crucial for `Prefix + M` marked-join workflow) |
| `Prefix + ;` | Switch focus back to the last active pane (great for fast toggling) |
| `Prefix + o` | Cycle focus to the next pane (by pane index) |
| `Prefix + q` | Briefly overlay pane index numbers on top of each pane |
| `Prefix + t` | Display a large digital clock (press any key to dismiss) |
| `Prefix + {` | Swap the current pane with the previous pane in index order |
| `Prefix + }` | Swap the current pane with the next pane in index order |
| `Prefix + Ctrl + o` | Rotate all panes in current window forward |
| `Prefix + Alt + o` | Rotate all panes in current window backward |
| `Prefix + Space` | Cycle layout through presets (even-horizontal, even-vertical, tiled, etc.) |

### Sessions & Client Management

| Keybinding | Action |
|---|---|
| `Prefix + d` | **Detach** current client (leaves session running in background) |
| `Prefix + D` | Choose a specific client to detach from interactive menu |
| `Prefix + Alt + d` | **Detach all other clients** attached to the current session |
| `Prefix + (` | Switch to the previous session |
| `Prefix + )` | Switch to the next session |
| `Prefix + L` | Switch to the last active session/client |
| `Prefix + $` | Rename current session (prompt) |
| `Prefix + N` | Create a new named session (prompt) |

### Paste Buffers

| Keybinding | Action |
|---|---|
| `Prefix + ]` | Paste contents of the latest buffer |

### Miscellaneous Command Keys

| Keybinding | Action |
|---|---|
| `Prefix + :` | Open tmux command line prompt |
| `Prefix + ?` | List all current active keybindings (built-in help menu) |
| `Prefix + i` | Display status information about current window/pane |
| `Prefix + ~` | Show tmux log messages (useful for troubleshooting) |
| `Prefix + PageUp` | Immediately enter copy-mode and scroll up one page |

---

## 3. Quick Reference Card

```
NAVIGATION          PICKERS & TREES         RESURRECT
C-Space h/j/k/l     C-Space s  sessions     C-Space S  save
C-Tab / C-S-Tab     C-Space w  tree/win     C-Space R  restore
C-Space z  zoom     C-Space e  panes+prev   C-Space C-s  named save
C-Space `  last win C-Space f  projects     C-Space C-r  named restore

PANES               WORKSPACES              PALETTE
C-Space | / -       C-Space D  dev layout   C-Space /  everything
C-Space v  smart    C-Space M-D triage
C-Space g  join     C-Space T  btop
C-Space ,  win name C-Space K  fkill
C-Space .  pane name
```
