# Terminal Configs — macOS Keyboard Shortcuts Reference

Consolidated shortcut reference for this machine's terminal stack: **tmux** (prefix `Ctrl+Space`), **Neovim** (AstroNvim), **zsh**, **Ghostty**, and **Alacritty**. `~/.tmux.conf` and `~/.zshrc` are symlinked into this repo via GNU Stow, so editing the repo files edits your live config.

---

## 1. New / Changed in This Pass

Additions made on top of the existing setup (cross-referenced against a tmux workflow guide screenshot):

| Keybinding | Action |
|---|---|
| `Prefix + Alt-s` | **Stash** current window into a background `stash` session (created on demand); the job inside keeps running |
| `Prefix + Alt-r` | **Retrieve** ("unstash"): fuzzy-pick a window out of `stash` and move it back into the current session |
| `Prefix + s` | Fuzzy-pick and switch to any active **session** (fzf popup — replaces the plain built-in session tree) |
| `Prefix + w` | Fuzzy-pick and switch to any **window** in the current session (fzf popup — replaces the plain built-in window tree) |
| `Ctrl+h` / `Ctrl+j` / `Ctrl+k` / `Ctrl+l` | **Seamless Vim ⟷ tmux pane navigation** (no prefix). Passes through to Neovim splits when Neovim is the foreground process, otherwise moves the tmux pane focus. Requires the `christoomey/vim-tmux-navigator` Neovim plugin (added at `.config/nvim/lua/plugins/tmux-navigator.lua`) |
| `Ctrl+\` | Jump to the previously-focused pane/split (same passthrough logic as above) |
| — | Cursor shape fix: Neovim now correctly renders a **block cursor in Normal mode** and a **beam cursor in Insert mode** inside tmux (`Ss`/`Se` terminal-override) |
| — | `bin/tmux-sessionizer` now auto-launches `nvim .` the first time it creates a brand-new project session |

> **Note on Ctrl-h/j/k/l:** outside of Neovim, these now move tmux pane focus instead of their old shell meaning (e.g. `Ctrl+h` no longer backspaces, `Ctrl+k` no longer kills the readline line). This is the standard, intentional trade-off of `vim-tmux-navigator` — use `Backspace`/`Delete` and normal line-editing keys instead.

**Shell-level companions** (work outside tmux popups too), added to `.zshrc`:

| Command | Action |
|---|---|
| `tmux-stash` | Alias — move the current window to the background `stash` session |
| `tmux-unstash` | Function — fzf-pick a window out of `stash` and move it back to the current session |

---

## 2. tmux — Custom Keybindings (prefix: `Ctrl+Space`)

### Splitting & Navigation

| Keybinding | Action |
|---|---|
| `Prefix + \|` | Split pane vertically (left/right), inherits current directory |
| `Prefix + -` | Split pane horizontally (top/bottom), inherits current directory |
| `Prefix + h/j/k/l` | Move focus left/down/up/right (vim-style) |
| `Ctrl+h/j/k/l` (no prefix) | Move focus left/down/up/right **and** passthrough into Neovim splits |
| `Ctrl+\` (no prefix) | Jump to last-focused pane/split (tmux or Neovim) |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Cycle to next/previous pane (no prefix) |
| `Prefix + z` | Toggle pane zoom |
| `Prefix + \`` | Jump to last active window |
| `Prefix + b` | Toggle status bar visibility |
| `Prefix + v` | Smart split — horizontal if wide, vertical if tall |

### Pane Management

| Keybinding | Action |
|---|---|
| `Prefix + ← / ↓ / ↑ / →` | Swap/move current pane in that direction |
| `Prefix + H/J/K/L` | Resize pane by 5 cells (repeatable) |
| `Prefix + m` (default) | Mark active pane |
| `Prefix + M` | Join marked pane horizontally into current window |
| `Prefix + g` | Join pane — pick source interactively from tree |
| `Prefix + S` | Join pane — prompt for source window number |
| `Prefix + R` | Rename current pane title |
| `Prefix + x` | Kill active pane (no confirmation) |
| `Prefix + G` | Kill all other panes in the window |
| `Prefix + y` | Toggle pane synchronization |
| `Prefix + < / >` | Move active pane to previous/next window |
| `Prefix + B` | Break pane into its own new window |
| `Prefix + Alt-Shift-B` (`M-B`) | Break pane into a new **background** window |
| `Prefix + Alt-b` (`M-b`) | Promote all other panes in the window to background windows |
| `Prefix + Alt-j` (`M-j`) | Pull all panes from a specified window into this one |
| `Prefix + Alt-m` (`M-m`) | Push all panes of this window to another window |
| `Ctrl-b` (with prefix) | Toggle pane border visibility |
| `Prefix + Ctrl-g` | Centered floating `git status` popup |

### Windows & Sessions

| Keybinding | Action |
|---|---|
| `Prefix + c` | New window, inherits current directory |
| `Prefix + X` | Kill active window (no confirmation) |
| `Prefix + N` | New named session (prompts) |
| `Prefix + $` | Rename current session |
| `Prefix + D` | Detach all other clients |
| `Prefix + W` | High-info interactive tree (process, PID, activity) |
| `Prefix + s` | **Fuzzy session switcher (fzf)** |
| `Prefix + w` | **Fuzzy window switcher (fzf)** |
| `Prefix + Alt-s` | **Stash** window to background `stash` session |
| `Prefix + Alt-r` | **Retrieve/unstash** a window from `stash` |
| `Prefix + f` | Fuzzy project switcher (`tmux-sessionizer`) — jumps between git project sessions, auto-launches `nvim .` for brand-new sessions |
| `Prefix + r` | Reload `.tmux.conf` + confirmation toast |

### Copy Mode (vi-style)

| Keybinding | Action |
|---|---|
| `Prefix + Enter` or `Prefix + u` | Enter copy-mode (the latter also scrolls up half a page) |
| `Ctrl+h/j/k/l` / `Ctrl+\` | Move between panes/splits without leaving copy-mode |
| `v` | Begin selection |
| `Ctrl+v` | Toggle rectangle/block selection |
| `u` / `d` | Half-page up/down |
| `i` | Exit copy-mode (quick insert) |
| `f` | Extract URLs from the pane and fuzzy-pick one to open |
| `y` | Yank selection to system clipboard + toast |
| `Y` | Copy current line to clipboard + toast |
| Mouse drag release | Auto-copy selection to clipboard + toast |
| `Escape` | Cancel selection / exit copy-mode |

### Git Worktree & Claude Workflows

| Keybinding | Action |
|---|---|
| `Prefix + Ctrl-n` | Create a git worktree branch (prompt), open a window running Claude |
| `Prefix + Ctrl-a` | Fuzzy-pick an existing worktree, open a window running Claude |
| `Prefix + Ctrl-x` | Fuzzy-pick a worktree to remove (dir + branch) |
| `Prefix + a` | Open/reattach a persistent Claude popup session |
| `Prefix + Ctrl-p` | Open/reattach a **project-specific** Claude popup session (hashed by directory) |
| `Prefix + A` | Side-by-side Claude pane (35% width split) |
| `Prefix + Ctrl-c` | New window running Claude in the current directory |
| `Prefix + F` | Fuzzy-find a file path, copy it to the clipboard |

### Logging & Archiving

| Keybinding | Action |
|---|---|
| `Prefix + P` | Dump last 30,000 lines of scrollback to `~/tmux_archive_*.log` |
| `Prefix + Alt-l` | Toggle continuous logging of the active pane to `~/tmux-logs/` |
| `Prefix + Alt-p` | Screenshot the visible pane to `~/tmux-logs/` |
| `Prefix + Alt-Shift-P` | Save complete scrollback to `~/tmux-logs/` |
| `Prefix + Alt-c` | Clear scrollback history |
| — | Every pane is auto-logged to `~/tmux-logs/` from creation (no key needed) |

### Session Persistence (tmux-resurrect / tmux-continuum)

| Keybinding | Action |
|---|---|
| `Prefix + Ctrl-s` | Manually save the current tmux environment (all sessions/windows/panes/layout) |
| `Prefix + Ctrl-r` | Manually restore the last saved environment |
| — | Auto-restore on tmux/system restart is enabled (`@tmux-continuum-restore on`); pane contents are captured too |
| `Prefix + I` | Install any newly-declared TPM plugins |
| `Prefix + U` | Update installed TPM plugins |
| `Prefix + Alt-u` | Remove plugins no longer in `.tmux.conf` |

---

## 3. tmux — Unmodified Defaults Still Active

| Keybinding | Action |
|---|---|
| `Prefix + ,` | Rename current window |
| `Prefix + n` / `Prefix + p` | Next / previous window |
| `Prefix + 1`–`9` | Jump to window by index |
| `Prefix + .` | Move window (prompt) — e.g. type `stash:` to relocate a window into a session named `stash` by hand |
| `Prefix + '` | Select window by index prompt |
| `Prefix + ;` | Jump to last active pane |
| `Prefix + o` | Cycle to next pane by index |
| `Prefix + q` | Briefly show pane index numbers |
| `Prefix + t` | Big digital clock |
| `Prefix + { / }` | Swap current pane with previous/next in index order |
| `Prefix + Ctrl-o` / `Prefix + Alt-o` | Rotate panes forward/backward |
| `Prefix + !` | Break pane into a new window |
| `Prefix + Space` | Cycle layout presets |
| `Prefix + d` | Detach client |
| `Prefix + L` | Switch to last active session/client |
| `Prefix + ]` | Paste latest buffer |
| `Prefix + =` | List paste buffers, choose one |
| `Prefix + :` | tmux command prompt |
| `Prefix + ?` | List all active keybindings |
| `Prefix + i` | Window/pane status info |
| `Prefix + ~` | Show tmux log messages |
| `Prefix + PageUp` | Enter copy-mode, scroll up one page |

---

## 4. Neovim (AstroNvim) — tmux Integration

| Keybinding | Action |
|---|---|
| `Ctrl+h` | `TmuxNavigateLeft` — move to the split/pane on the left |
| `Ctrl+j` | `TmuxNavigateDown` |
| `Ctrl+k` | `TmuxNavigateUp` |
| `Ctrl+l` | `TmuxNavigateRight` |
| `Ctrl+\` | `TmuxNavigatePrevious` — jump back to the last split/pane |

Plugin spec: `.config/nvim/lua/plugins/tmux-navigator.lua` (`christoomey/vim-tmux-navigator`). Run `Prefix + I` in tmux (already sourced) — the Neovim side installs automatically via lazy.nvim on next launch. Deeper LSP-specific bindings are documented separately in `docs/LSP_SHORTCUTS.md`.

---

## 5. zsh Aliases & Functions (tmux-related)

| Command | Action |
|---|---|
| `ta` | Attach to `main` session, or create it if missing |
| `tl` | List all tmux sessions |
| `tk <name>` | Kill a named tmux session |
| `tmux-stash` | Move current window to the background `stash` session |
| `tmux-unstash` | Fuzzy-pick a window out of `stash`, move it back |

---

## 6. Ghostty (terminal-level)

| Keybinding | Action |
|---|---|
| `Cmd+D` | New split, right |
| `Cmd+Shift+D` | New split, down |
| `Cmd+H / Cmd+L` | Focus split left / right |
| `Cmd+K / Cmd+J` | Focus split top / bottom |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Cycle tmux panes (sent through as tmux's C-Tab/C-BTab sequence) |

## 7. Alacritty (terminal-level)

| Keybinding | Action |
|---|---|
| `Shift+Return` | Custom binding (see `alacritty.toml`) |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Cycle tmux panes (belt-and-suspenders alongside Ghostty's) |

---

*Generated from a live audit of `~/Github/2026/terminal-configs` — regenerate by re-reading `.tmux.conf`, `.zshrc`, `bin/tmux-sessionizer`, and the nvim `plugins/` directory if configs change.*
