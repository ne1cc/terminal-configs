# Tmux Production Setup — Logging & Verification Changelog

_Generated 2026-06-10 · target file: `.tmux.conf` (Stow-managed → `~/.tmux.conf`) · tmux 3.6b · Alacritty + Wayland_

This document summarizes everything applied in this session. Each entry follows:
**Feature → Summary → Code & Fix → Next Steps / Future Considerations.**

---

## 1. Production config applied & validated

### Summary
The working-tree `.tmux.conf` was confirmed **byte-for-byte identical** to the supplied
production config, then reloaded live into the running server with no errors. Prefix
(`C-Space`), top status bar, `vi` mode, and `extended-keys on` were all verified active.
The three pre-existing plugins (`tpm`, `tmux-resurrect`, `tmux-continuum`) were confirmed
loaded — resurrect's `prefix+C-s`/`prefix+C-r` bindings exist and continuum injected its
auto-save hook into `status-right`.

A trailing `debug this` fragment on the supplied TPM init line was **treated as a stray
artifact, not an instruction**. The file already ended with the correct line, so nothing
had to change.

### Code & Fix
```tmux
# Correct, final line of the file (the stray "debug this" was NOT introduced):
run '~/.tmux/plugins/tpm/tpm'
```
```bash
tmux source-file ~/.tmux.conf        # → sourced, no errors
tmux show -g prefix                   # → C-Space
tmux show -g status-position          # → top
```

### Next Steps / Future Considerations
- Nothing required. The committed config and the running server are in sync.

---

## 2. Always-on automatic pane logging

### Summary
Every pane now streams a **complete copy of its output** to `~/tmux-logs/` from the moment
it is created — no keypress required. Filenames encode `session-window.pane` plus a
creation timestamp, so concurrent panes never collide. This is the "production logging"
backbone: it captures everything, automatically, across new sessions, new windows, and
splits. Hooks cover all *future* panes; a one-time loop was run to begin logging the
panes that were already open.

Key reliability properties (each verified empirically on tmux 3.6b):
- `pipe-pane` **format-expands `#{...}`** against the target pane.
- `$(date ...)` is evaluated **once** by the shell when the pipe opens (stable filename).
- The **`-o` flag is idempotent** — an already-piped pane is left alone, so re-sourcing the
  config and resurrect/continuum restores will **not** create duplicate pipes.
- Output is appended (`>>`), so a re-attached pane keeps a single continuous file.

### Code & Fix
```tmux
# ==============================================================================
# AUTOMATIC PANE LOGGING — always-on, every pane
# ==============================================================================
set-hook -g after-new-session  'pipe-pane -o "mkdir -p ~/tmux-logs && cat >> ~/tmux-logs/auto-#{session_name}-#{window_index}.#{pane_index}-$(date +%Y%m%dT%H%M%S).log"'
set-hook -g after-new-window   'pipe-pane -o "mkdir -p ~/tmux-logs && cat >> ~/tmux-logs/auto-#{session_name}-#{window_index}.#{pane_index}-$(date +%Y%m%dT%H%M%S).log"'
set-hook -g after-split-window 'pipe-pane -o "mkdir -p ~/tmux-logs && cat >> ~/tmux-logs/auto-#{session_name}-#{window_index}.#{pane_index}-$(date +%Y%m%dT%H%M%S).log"'
```
```bash
# One-time: start logging panes that already existed at reload time
tmux list-panes -a -F '#{pane_id}|#{session_name}|#{window_index}|#{pane_index}' \
  | while IFS='|' read id s w p; do
      tmux pipe-pane -o -t "$id" \
        "mkdir -p ~/tmux-logs && cat >> ~/tmux-logs/auto-${s}-${w}.${p}-$(date +%Y%m%dT%H%M%S).log"
    done
# Verified: every pane reports pane_pipe=1; new-pane smoke test produced pipe=1.
```

### Next Steps / Future Considerations
- **Log rotation / cleanup.** Files grow unbounded. Add a periodic cleanup (e.g. a cron or
  systemd-timer running `find ~/tmux-logs -type f -mtime +14 -delete`).
- **`.gitignore`.** Ensure `~/tmux-logs/` (or the repo path, if ever symlinked) is never
  committed.
- **Sensitive output.** Passwords/tokens echoed to a pane land in plaintext logs — consider
  excluding sensitive sessions (skip the hook when a `@no-log` option is set) if needed.
- **Reboot coverage.** continuum/resurrect recreate panes via new-window/split, which fire
  the hooks, so restored sessions self-log. Worth re-verifying after the next real reboot.

---

## 3. `tmux-logging` plugin — manual captures (key conflict resolved)

### Summary
Added `tmux-plugins/tmux-logging` for **on-demand** capture alongside the always-on stream:
toggle logging, screen-capture the visible pane, dump full scrollback, and clear history.
The plugin's default toggle key is `P`, which **would have clobbered your `prefix+P`
archive binding**. Fixed by moving the toggle to `M-l`, grouping it with the plugin's other
Alt-based commands, and pointing all output paths at `~/tmux-logs/`. Verified that
`prefix+P` still runs your `capture-pane … save-buffer` archive after the plugin loads.

| Binding         | Action                                   |
|-----------------|------------------------------------------|
| `prefix + M-l`  | Toggle continuous logging of current pane |
| `prefix + M-p`  | Screen-capture visible pane contents      |
| `prefix + M-P`  | Save complete scrollback history          |
| `prefix + M-c`  | Clear current pane history                |
| `prefix + P`    | (unchanged) your timestamped archive      |

### Code & Fix
```tmux
set -g @plugin 'tmux-plugins/tmux-logging'

# Toggle key moved off default 'P' (owned by the archive binding) → Alt-l.
# NOTE: the toggle option uses an UNDERSCORE (@logging_key); the others use hyphens.
set -g @logging_key 'M-l'
set -g @logging-path               "$HOME/tmux-logs"
set -g @screen-capture-path        "$HOME/tmux-logs"
set -g @save-complete-history-path "$HOME/tmux-logs"
```
```bash
~/.tmux/plugins/tpm/bin/install_plugins   # installs tmux-logging
tmux list-keys | grep -E 'logging|capture|history'   # → M-l, M-p, M-P, M-c bound
```

### Next Steps / Future Considerations
- The manual **toggle** is largely redundant now that auto-logging is on; its real value is
  *stopping* logging for a noisy pane. `M-p`/`M-P` (screen-capture / full-history dumps)
  remain the most useful for ad-hoc snapshots.
- Consider tuning `@logging-filename` / `@screen-capture-filename` if you want manual
  captures to sort separately from the `auto-*` stream files (they already prefix
  `tmux-` vs `auto-`, so they're distinguishable).

---

## 4. Clipboard on Wayland (flagged, not yet changed)

### Summary
The copy bindings use the chain `xclip → xsel → pbcopy`. `xclip` is installed and works via
XWayland, so copy currently functions. However the session is **native Wayland** and
`wl-copy` is installed but **not** in the chain. Left the production config untouched
pending your go-ahead.

### Code & Fix
```tmux
# Current (works under XWayland):
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel \
  "xclip -in -selection clipboard 2>/dev/null || xsel --clipboard --input 2>/dev/null || pbcopy" \
  \; display-message "✓ Copied #{buffer_size} bytes to clipboard"

# Proposed (native Wayland first, X11 fallback) — NOT YET APPLIED:
#   "wl-copy 2>/dev/null || xclip -in -selection clipboard 2>/dev/null || xsel --clipboard --input 2>/dev/null || pbcopy"
```

### Next Steps / Future Considerations
- Decide whether to prepend `wl-copy` to both `y` and `MouseDragEnd1Pane` copy bindings for
  a more native Wayland path. One word and it's done.

---

## Verification summary

| Check | Result |
|-------|--------|
| `tmux source-file ~/.tmux.conf` | ✓ no errors |
| Plugins present | `tpm`, `tmux-resurrect`, `tmux-continuum`, `tmux-logging` |
| All open panes piping | ✓ `pane_pipe=1` on every pane |
| New-pane hook | ✓ fresh pane reported `pipe=1` |
| `prefix+P` archive intact | ✓ still bound to `capture-pane … save-buffer` |
| Manual logging keys | ✓ `M-l`, `M-p`, `M-P`, `M-c` bound |
| Auto-log files written | ✓ `~/tmux-logs/auto-*.log` accumulating output |
