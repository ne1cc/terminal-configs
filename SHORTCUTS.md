# Terminal Shortcuts Reference

> **Stack:** Ghostty 1.3.1 → tmux (prefix: `Ctrl+Space`) → shell
>
> All tmux shortcuts require the prefix (`Ctrl+Space`) unless marked **no prefix**.

---

## Ghostty (app-level)

| Shortcut | Action |
|---|---|
| `Ctrl+Tab` | Cycle tmux panes forward |
| `Ctrl+Shift+Tab` | Cycle tmux panes backward |
| `Super+Shift+]` | Next Ghostty tab |
| `Super+Shift+[` | Previous Ghostty tab |

---

## tmux — Panes

| Shortcut | Action |
|---|---|
| `Prefix + \|` | Split vertically (new pane right, same dir) |
| `Prefix + -` | Split horizontally (new pane below, same dir) |
| `Prefix + h` | Focus pane left |
| `Prefix + j` | Focus pane down |
| `Prefix + k` | Focus pane up |
| `Prefix + l` | Focus pane right |
| `Ctrl+Tab` *(no prefix)* | Cycle to next pane |
| `Ctrl+Shift+Tab` *(no prefix)* | Cycle to previous pane |
| `Prefix + ←` | Swap pane left |
| `Prefix + ↓` | Swap pane down |
| `Prefix + ↑` | Swap pane up |
| `Prefix + →` | Swap pane right |
| `Prefix + M` | Join marked pane horizontally (horizontal split) |
| `Prefix + g` | Join pane — pick from interactive tree (was `j`) |
| `Prefix + S` | Join pane — prompt for source window number |
| `Prefix + z` | Zoom/unzoom current pane (fullscreen toggle) |
| `Prefix + x` | Kill current pane |

---

## tmux — Windows

| Shortcut | Action |
|---|---|
| `Prefix + c` | New window (opens in current directory) |
| `Prefix + ,` | Rename current window |
| `Prefix + n` | Next window |
| `Prefix + p` | Previous window |
| `Prefix + 1`–`9` | Jump to window by number |
| `Prefix + &` | Kill current window |
| `Prefix + w` | Interactive window list |

---

## tmux — Sessions

| Shortcut | Action |
|---|---|
| `Prefix + $` | Rename current session |
| `Prefix + s` | Switch between sessions |
| `Prefix + d` | Detach from session |
| `Prefix + W` | High-info process tree (PID, last activity, active pane) |

---

## tmux — Copy Mode

| Shortcut | Action |
|---|---|
| `Prefix + [` | Enter copy mode |
| `q` | Exit copy mode |
| `v` | Begin selection (vi mode) |
| `y` | Copy selection → macOS clipboard |
| Mouse drag | Select and copy to clipboard (auto) |
| `Prefix + ]` | Paste |

---

## tmux — Misc

| Shortcut | Action |
|---|---|
| `Prefix + :` | Open tmux command prompt |
| `Prefix + ?` | List all keybindings |
| `Prefix + t` | Show clock |
| `Prefix + Space` | Send literal `Ctrl+Space` to shell |

---

## Learning Path

### Immediate (get comfortable this week)
- [ ] Use `Prefix + |` and `Prefix + -` instead of opening new Ghostty windows
- [ ] Navigate panes with `Prefix + h/j/k/l` and `Ctrl+Tab`
- [ ] Use `Prefix + c` for new windows, `Prefix + 1-9` to jump between them
- [ ] Use `Prefix + z` to zoom into a pane when you need focus

### Short-term (build muscle memory)
- [ ] Learn copy mode: `Prefix + [`, vi motions, `v` to select, `y` to yank
- [ ] Use `Prefix + W` to get an overview of all running processes
- [ ] Use `Prefix + $` and `Prefix + ,` to name sessions and windows
- [ ] Learn `Prefix + d` to detach and `tmux attach` to come back

### Level up
- [ ] Name sessions per project: `tmux new-session -s myproject`
- [ ] Use `Prefix + s` to switch between project sessions without losing state
- [ ] Learn `Prefix + M` (join marked) and `Prefix + g` to rearrange panes across windows
- [ ] Read `man tmux` for the target syntax (`:`, `.`, `+`, `-` notation)
