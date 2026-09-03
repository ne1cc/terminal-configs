# Terminal Emulators & Keyboard Guide

Ghostty, Alacritty, and Karabiner-Elements — how they integrate with tmux and why certain keys work the way they do.

**Configs:**
- `.config/ghostty/config`
- `.config/alacritty/alacritty.toml`
- `.config/karabiner/karabiner.json`

---

## Quick start

Both terminal emulators auto-attach to tmux session **`main`** on launch.

```bash
# If tmux isn't running, opening Ghostty/Alacritty creates:
tmux new-session -s main
```

Use **Ghostty** as primary (GPU, native tabs). Use **Alacritty** for breakout sessions (`Prefix + Alt + a`).

---

## Ghostty

### tmux integration

- On start: attach to `main` or create it
- Passes extended key sequences for `Ctrl + Tab` / `Ctrl + Shift + Tab` ? tmux pane cycling
- Supports Kitty graphics protocol (Neovim images, Yazi previews)

### Native window keys

| Key | Action |
|-----|--------|
| `Cmd + d` | Split surface right |
| `Cmd + Shift + d` | Split surface down |
| `Cmd + h/l` | Focus surface left/right |
| `Cmd + k/j` | Focus surface top/bottom |
| `Cmd + Shift + ]` | Next native tab |
| `Cmd + Shift + [` | Previous native tab |

Native Ghostty splits are separate from tmux splits — most workflow uses tmux inside one Ghostty window.

### Extended keys (tmux)

| Key | Sent as | tmux action |
|-----|---------|-------------|
| `Ctrl + Tab` | `\x1b[27;5;9~` | Next pane |
| `Ctrl + Shift + Tab` | `\x1b[27;6;9~` | Previous pane |

Without this, tmux couldn't distinguish Tab from modified Tab.

---

## Alacritty

### tmux integration

- **Dynamic attach:** re-attaches to `main` if idle; creates new session if `main` is already attached elsewhere
- **Zero scrollback:** scrolling happens in tmux copy-mode — keeps pane state consistent

### Keys

| Key | Action |
|-----|--------|
| `Ctrl + Shift + U` | URL / regex hint selector |
| `Shift + Return` | Raw escape return |
| `Ctrl + Tab` | Extended sequence ? tmux |
| `Ctrl + Shift + Tab` | Extended sequence ? tmux |

### When to use

- `Prefix + Alt + a` — break pane into new Alacritty window
- Second monitor workflows
- Lightweight fallback if Ghostty unavailable (Linux)

---

## Karabiner-Elements (macOS)

Config: `.config/karabiner/karabiner.json`

### Window cycling

| Key | Maps to | Action |
|-----|---------|--------|
| `Cmd + Option + h` | `Cmd + Shift + \`` | Cycle app window backward |
| `Cmd + Option + l` | `Cmd + \`` | Cycle app window forward |

Useful when multiple Ghostty/tmux sessions are open.

### Ergonomic modifier

| Key | Maps to |
|-----|---------|
| **Right Option** | **Left Control** |

Makes tmux prefix (`Ctrl + Space`) and terminal chords easier — right hand on Space, left on modified keys.

---

## Starship prompt

Config: `.config/starship.toml`

Cross-shell prompt showing git branch, directory, language tool versions. Loaded in `.zshrc`.

---

## Font

**JetBrainsMono Nerd Font** — required for icons in eza, starship, Lazygit, Yazi.

Installed via Brewfile. WSL bootstrap copies to Windows fonts for cross-platform terminals.

---

## Bootstrap per platform

| Script | Terminal setup |
|--------|----------------|
| `mac-bootstrap.sh` | Installs Ghostty via Brewfile |
| `linux-bootstrap.sh` | Alacritty/Ghostty via Linuxbrew |
| `wsl-bootstrap.sh` | Fonts copied to Windows; use Ghostty/Alacritty on Windows side |

Full walkthrough: [GITHUB_WORKSPACE_SETUP.md](GITHUB_WORKSPACE_SETUP.md)

---

## macOS performance defaults

Optional tuning via `bin/macos-defaults.sh`:

- Fast key repeat
- Finder tweaks
- Reduced animations

Run manually after bootstrap if desired.

---

## Daily workflows

### Normal day — one Ghostty window

```
Open Ghostty ? auto-attaches main tmux
Prefix + f ? pick project
Prefix + D ? dev layout
```

### Second monitor — breakout

```
Prefix + Alt + g    ? break pane to new Ghostty
Prefix + @           ? break whole window to new Ghostty
```

### Cycle between tmux sessions in same app

```
Cmd + Option + l    ? next window (Karabiner)
Prefix + s          ? fzf session picker (better)
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Ghostty doesn't attach tmux | Check config `command` setting; run `ta` manually |
| Breakout opens `main` instead of breakout session | Fixed in `tmux-breakout-ghostty` via `--command=`; reload config (`Prefix + r`) |
| `Prefix + Alt + g` returns exit 1 | Reload config — binding must pass `#{pane_id}` (`TMUX_PANE` is empty under `run-shell -b`) |
| `Ctrl + Tab` doesn't work | Must use Ghostty/Alacritty — not all terminals send CSI |
| Icons show boxes | Install Nerd Font; set terminal font to JetBrainsMono Nerd Font |
| Right Option feels wrong | Disable Karabiner remap or adjust in karabiner.json |
| Alacritty no scrollback | By design — use tmux copy-mode (`Prefix + Enter`) |
| WSL clipboard broken | Run `wsl --shutdown`; check `/etc/wsl.conf` interop |

---

## Related docs

- [TMUX_WORKFLOW_GUIDE.md](TMUX_WORKFLOW_GUIDE.md) — everything inside tmux
- [NEOVIM_GUIDE.md](NEOVIM_GUIDE.md) — image protocol requirements
- [GITHUB_WORKSPACE_SETUP.md](GITHUB_WORKSPACE_SETUP.md) — install Ghostty/fonts

---

## Cheat sheet

```
Ghostty:     Cmd+d split  Cmd+h/j/k/l focus  Cmd+Shift+[/] tabs
Alacritty:   Prefix+Alt+a breakout  Ctrl+Shift+U URLs
Karabiner:   Cmd+Opt+h/l window cycle  Right Opt ? Ctrl
tmux:        Ctrl+Tab pane cycle  ta attach main
```
