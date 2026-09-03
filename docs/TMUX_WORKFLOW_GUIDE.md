# tmux Workflow Guide

A practical guide to tmux in this setup: navigation, layouts, AI assistants, project switching, and session persistence.

**Prefix key:** `Ctrl + Space` (most prefixed commands)  
**Cheatsheet:** [TMUX_SHORTCUTS.md](../TMUX_SHORTCUTS.md) — every binding in table form

---

## Quick start

```bash
ta                    # attach to session "main" (or create it)
Prefix + /            # command palette — search any workflow
Prefix + f            # sessionizer — fuzzy jump to a git project
Prefix + D            # dev workspace layout (editor + server + shell)
Prefix + Shift + H    # session handoff — save state for AI resume
```

If you're not in tmux yet, Ghostty and Alacritty auto-attach to `main` on launch.

---

## Mental model

```
tmux server
??? session (e.g. olist-lakehouse)
    ??? window (tab)
        ??? pane (split)
```

- **Session** = one project or context (often named after the repo)
- **Window** = tab within a session (editor, logs, shell, git)
- **Pane** = split within a window

Navigation uses Vim keys (`h/j/k/l`) without prefix for pane focus — same keys work in Neovim.

---

## Seamless navigation (no prefix)

| Keys | Action |
|------|--------|
| `Ctrl + h/j/k/l` | Focus pane left/down/up/right |
| `Ctrl + \` | Jump to last-focused pane |
| `Ctrl + Tab` | Next pane |
| `Ctrl + Shift + Tab` | Previous pane |
| `Shift + ?/?` | Previous/next window |

These work from Neovim and the shell — tmux and Neovim share the same navigation layer.

---

## Splitting & layout

| Keys | Action |
|------|--------|
| `Prefix + \|` | Vertical split (side by side) |
| `Prefix + -` | Horizontal split (stacked) |
| `Prefix + v` | Smart split — horizontal if wide screen, vertical if tall |
| `Prefix + z` | Zoom/maximize active pane |
| `Prefix + =` | Rebalance/tilt all panes evenly |
| `Prefix + c` | New window (inherits `$PWD`) |

Inactive panes are dimmed (Tokyo Night palette) so focus is obvious.

---

## Declarative workspaces

Instant IDE layouts via `tmux-workspace`:

| Trigger | Layout | Panes |
|---------|--------|-------|
| `Prefix + Shift + D` | **dev** | Editor 65% + dev server + shell (35% stack) |
| `Prefix + Alt + Shift + D` | **triage** | 2×2 grid: git, editor, logs, shell |
| Shell: `tmux-workspace ai` | **ai** | Editor 60% + Claude 40% side-by-side |

```bash
# From shell inside tmux
tmux-workspace dev
tmux-workspace triage
tmux-workspace ai
```

Use **dev** for normal feature work, **triage** when debugging CI/logs across multiple sources, **ai** when pair-programming with Claude.

---

## Command palette

`Prefix + /` opens the **tmux command palette** — fuzzy search every workflow:

- Agent matrix (parallel AI agents)
- Session handoff
- Dev/triage workspace layouts
- Port inspector & killer
- Cheat.sh docs
- Dotfiles editor
- File/stacktrace jumper → Neovim
- Scratchpad notes
- Docker exec, SSH jumper
- Session/window/pane switchers
- Stash/unstash windows
- Claude & Antigravity popups
- Lazygit modal
- Named session snapshots

**Tip:** If you forget a binding, start here.

---

## Project switching (sessionizer)

`Prefix + f` runs **tmux-sessionizer**:

1. Fuzzy-lists git project folders under `~/Github`
2. Creates session named after the repo (if missing)
3. Switches to that session

Also available from the palette and shell:

```bash
tmux-sessionizer                    # interactive
tmux-sessionizer ~/Github/n1ecC/olist-lakehouse   # direct
```

**Shell aliases:**

```bash
ta          # tmux attach -t main || tmux new-session -s main
tl          # list sessions
tk <name>   # kill session
```

---

## Window & session pickers

| Keys | Action | Mechanism |
|------|--------|-----------|
| `Prefix + s` | Switch session | `fzf` popup |
| `Prefix + w` | Interactive tree/window picker (collapsed panes) | `choose-tree -Zw` (with `h`/`l`/`H`/`L` fold) |
| `Prefix + e` | Switch pane (all sessions with live preview) | `fzf` popup |
| `Prefix + f` | Sessionizer (git projects) | `fzf` popup |
| `Prefix + \`` / `Prefix + Tab` | Last window bounce | instant |

**Tree Mode Navigation (inside `Prefix + w`):**
- `h` / `l`: Collapse / expand highlighted item
- `H` / `L`: Collapse / expand all sessions
- `Enter`: Select and switch to window or session
- `q` / `Esc`: Dismiss picker

---

## Window stashing (scratchpads)

Hide windows without killing them — useful for long-running servers or reference terminals.

| Keys | Action |
|------|--------|
| `Prefix + Alt + s` | Stash current window → background `stash` session |
| `Prefix + Alt + r` | Retrieve stashed window back into current session |

---

## AI assistant integration

### Claude Code

| Keys | Action |
|------|--------|
| `Prefix + a` | Persistent centered Claude popup |
| `Prefix + Ctrl + p` | Project-specific Claude popup (hash of `$PWD`) |
| `Prefix + Shift + A` | Side-by-side Claude pane (35% width) |
| `Prefix + Ctrl + c` | Full window running Claude in `$PWD` |

### Antigravity (YOLO mode)

| Keys | Action |
|------|--------|
| `Prefix + Alt + y` | Persistent centered Antigravity popup (`agyy`) |

### Agent matrix

| Keys | Action |
|------|--------|
| `Prefix + Ctrl + t` | Tile 2, 3, or 4 parallel AI agents |

Shell equivalent:

```bash
matrix 2    # 2-pane agent grid
matrix 3
matrix 4
```

### Git worktrees + Claude

| Keys | Action |
|------|--------|
| `Prefix + Ctrl + n` | Create worktree branch → open Claude window |
| `Prefix + Ctrl + a` | Pick existing worktree → open Claude window |
| `Prefix + Ctrl + x` | Remove worktree + branch |

Shell equivalents: `wt-new`, `wt-tmux-attach`, `wt-rm` — see [ZSH_GIT_WORKFLOW_GUIDE.md](ZSH_GIT_WORKFLOW_GUIDE.md).

---

## Lazygit & Git in tmux

| Keys | Action |
|------|--------|
| `Prefix + Ctrl + g` | Floating Lazygit (90% centered modal) |
| `Prefix + Shift + F` | Fuzzy find file → copy relative path to clipboard |

See [LAZYGIT_GUIDE.md](LAZYGIT_GUIDE.md) for AI keys inside Lazygit.

---

## Session handoff

Save git state + environment for AI resume:

| Trigger | Output |
|---------|--------|
| `Prefix + Shift + H` | Markdown handoff in `.gemini/sessions/` |
| Shell: `handoff [topic]` | Same |

Handoff includes: branch, recent commits, diff stats, toolchains, listening ports, tmux session info.

Resume prompt for Antigravity:

> *"Resume from `.gemini/sessions/latest.md` and continue implementation."*

---

## Moving, breaking & breakout workflows

Reorganize panes across windows and sessions, or pop them out into new terminal windows:

### Break & join panes
| Keys | Action | Scope |
|------|--------|-------|
| `Prefix + !` | Break active pane into a new foreground window | Current Session |
| `Prefix + Alt + Shift + B` (`M-B`) | Break active pane into a background window (`-d`) | Current Session |
| `Prefix + Alt + b` (`M-b`) | Demote all other panes into background windows | Current Window |
| `Prefix + Alt + j` (`M-j`) | Pull all panes from a chosen window into current window (tiled) | Current Window |
| `Prefix + Alt + m` (`M-m`) | Push all panes from current window to another window (tiled) | Current Window |
| `Prefix + g` | Join panes with fuzzy multi-select and preview (`bin/tmux-join-panes`) | Server |
| `Prefix + <` / `Prefix + >` | Move active pane to previous / next window | Current Session |

### Break out into sessions & multi-terminal
| Keys | Action |
|------|--------|
| `Prefix + Alt + p` (`M-p`) | Break pane → new tmux session (prompts name, auto-switches) |
| `Prefix + Alt + w` / `Prefix + Ctrl + w` | Break window → new tmux session (prompts name, auto-switches) |
| `Prefix + Alt + g` | Break pane → new tmux session → new Ghostty window (`bin/tmux-breakout-ghostty`) |
| `Prefix + Alt + a` | Break pane → new Alacritty window |
| `Prefix + @` | Break window → new Ghostty process |
| `Prefix + d` | Detach current client |
| `Prefix + Alt + d` (`M-d`) | Detach all other clients attached to current session |

Useful when you want a project on a second monitor without losing the original layout.

---

## Copy mode & clipboard

| Keys | Action |
|------|--------|
| `Prefix + Enter` | Enter vi copy-mode |
| `v` / `V` | Visual select (char / line) |
| `y` | Yank to system clipboard |
| Mouse drag | Auto-copy on release |

Shell: `copylast` captures previous command output — see [ZSH_GIT_WORKFLOW_GUIDE.md](ZSH_GIT_WORKFLOW_GUIDE.md).

---

## Session persistence

### tmux-resurrect (default snapshot)

| Keys | Action |
|------|--------|
| `Prefix + Shift + S` | Save session state |
| `Prefix + Shift + R` | Restore session state |

### Named snapshots

| Keys | Action |
|------|--------|
| `Prefix + Ctrl + s` | Save named snapshot (prompts for name) |
| `Prefix + Ctrl + r` | Restore named snapshot (fzf picker) |

Stored in `~/.tmux/resurrect/named/`.

### Logging

| Keys | Action |
|------|--------|
| `Prefix + Shift + P` | Dump 30k lines scrollback to `~/tmux_archive_*.log` |
| `Prefix + Alt + l` | Toggle continuous pane logging → `~/tmux-logs/` |
| `Prefix + Alt + p` | Screenshot visible pane |
| `Prefix + Alt + Shift + P` | Save full scrollback buffer |

---

## Utility scripts (bin/)

| Script | Purpose |
|--------|---------|
| `tmux-palette` | Command palette HUD |
| `tmux-workspace` | dev / ai / triage layouts |
| `tmux-sessionizer` | Fuzzy project switcher |
| `tmux-agent-matrix` | Parallel AI agent grid |
| `session-handoff` | Git + session markdown export |
| `tmux-ports` | Port inspector & killer |
| `tmux-cheat` | cheat.sh documentation HUD |
| `tmux-dotfiles` | Fuzzy edit configs |
| `tmux-open-path` | Jump file:line from screen → Neovim |
| `tmux-scratchpad` | Floating notes (`~/notes/scratchpad.md`) |
| `tmux-save-named` / `tmux-restore-named` | Named snapshots |
| `tmux-join-panes` | Multi-select pane joiner |

---

## Daily workflows

### Morning

```bash
ta
ghsync-pull
Prefix + f          # pick today's project
Prefix + D          # dev layout
```

### Feature branch with AI

```bash
Prefix + Ctrl + n   # new worktree + Claude window
# ... implement ...
handoff "auth middleware done"
```

### Debug CI failure

```bash
Prefix + Alt + Shift + D   # triage 2×2 grid
Prefix + Ctrl + g          # Lazygit for diff review
Prefix + Shift + O         # jump to error file:line in Neovim
```

### End of day

```bash
Prefix + Shift + H         # handoff note
Prefix + Ctrl + s          # named snapshot "eod-aug23"
Prefix + d                 # detach
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Prefix not working | Ensure `Ctrl + Space` isn't captured by OS; check Karabiner |
| `Ctrl + Tab` doesn't cycle panes | Use Ghostty/Alacritty — they send extended key sequences |
| Sessionizer finds no projects | Projects must be under `~/Github`; run `ghsync` first |
| Palette command fails | Run `install.sh` to refresh `~/bin` symlinks |
| Resurrect restore broken | Update TPM plugins: `Prefix + Shift + U` |
| Reload config | `Prefix + r` or `tmux source ~/.tmux.conf` |

---

## Cheat sheet

```
Navigation:     Ctrl+h/j/k/l    Prefix+z (zoom)    Prefix+= (tile)
Workspaces:     Prefix+D (dev)  Prefix+M-D (triage)
Switch:         Prefix+f (project)  Prefix+s (sess fzf)  Prefix+w (tree)  Prefix+e (pane fzf)
Break/Move:     Prefix+! (break) Prefix+M-p (to sess) Prefix+C-w (win to sess) Prefix+g (join)
AI:             Prefix+a (Claude)  Prefix+Alt+y (Antigravity)  Prefix+Ctrl+t (matrix)
Git:            Prefix+Ctrl+g (Lazygit)
Tools:          Prefix+/ (palette)  Prefix+Shift+H (handoff)
Stash:          Prefix+Alt+s / Prefix+Alt+r
Persist:        Prefix+Shift+S/R   Prefix+Ctrl+s/r (named)
```
