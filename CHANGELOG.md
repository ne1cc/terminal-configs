# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Changed — GitHub handle rename (n1ecC → ne1cc)
- Renamed the scaffolded workspace folder `~/Github/n1ecC/` → `~/Github/ne1cc/` across all scripts, configs, docs, agent memory, and templates: `.gitconfig` includeIf blocks, `.zshrc` / `.zprofile` (incl. `ghn`/`ghr`/`ghsync` aliases), `bin/setup-github-workspace`, `bin/gh-mirror-check` default owner, `bin/gharchive` (`--from-n1ecc` → `--from-ne1cc`), `bin/pin-portfolio`, `.config/sesh/sesh.toml`, and `templates/github-workspace/`.
- Script rename: `bin/sync-n1ecC` → `bin/sync-ne1cc`; env var `N1ECC_DIR` → `NE1CC_DIR`.
- After pulling, re-run `bin/setup-github-workspace` to refresh the `~/Github/_tools/sync-ne1cc` symlink.

### Added / Changed — Tmux Session & Window Management, Ghostty Multi-Session
- `.tmux.conf`: Re-enabled interactive zoomed tree picker on `Prefix + w` (`choose-tree -Zw`) with pane details collapsed for clean navigation.
- `.tmux.conf`: Added vim-style fold navigation keys in `tree-mode` (`h` collapse item, `l` expand item, `H` collapse all, `L` expand all).
- `bin/ghostty-new-session`: Added script to spawn fresh, uniquely-timestamped (`YYYY-MM-DD_HH-MM`) tmux sessions when launching new Ghostty windows (`Cmd+N`).
- `.config/ghostty/config`: Configured `initial-command = tmux new-session -A -s main` and `command = /Users/alex/bin/ghostty-new-session` so the initial surface attaches to `main` while subsequent windows spawn isolated sessions.
- `.zshrc`: Updated `ghostty-new()` timestamp naming format.
- Documentation: Fully audited and updated `SHORTCUTS.md`, `TMUX_SHORTCUTS.md`, `docs/TMUX_WORKFLOW_GUIDE.md`, and `docs/TERMINAL_EMULATORS_GUIDE.md` covering all pane breaking, joining, session moving, and tree navigation shortcuts. Cleaned documentation to UTF-8 encoding.

### Added — Ghostty pane breakout (`tmux-breakout-ghostty`)
- New script `bin/tmux-breakout-ghostty`: breaks the active pane into a fresh tmux session and opens it in a new Ghostty window.
- macOS fix: Ghostty launched via `open` ignores `-e`; pass `--command=tmux attach-session -t …` to override the default `command = tmux new-session -A -s main` in ghostty config.
- `Prefix + Alt + g` binding passes `#{pane_id}` explicitly (required because `run-shell -b` clears `TMUX_PANE`).
- Command palette entry: **Break Pane → Ghostty**.
- `Prefix + @` (break whole window → Ghostty) updated to use the same `--command=` launch pattern.

### Added — Antigravity / Gemini Skills & Markdown Rules
- Added all 100+ Antigravity skills (including newly created `markdown-architect` and full domain suites) to `.gemini/skills/`.
- Tracked global formatting rules `GEMINI.md` in repository root under `.gemini/GEMINI.md`.
- Updated [setup.sh](file:///Users/alex/Github/config/terminal-configs/setup.sh), [install.sh](file:///Users/alex/Github/config/terminal-configs/install.sh), and [bin/mac-bootstrap.sh](file:///Users/alex/Github/config/terminal-configs/bin/mac-bootstrap.sh) to automatically link `.gemini/skills` and `GEMINI.md` into `~/.gemini/config/` and `$HOME` across all machines.

### Changed — Neovim Neo-tree Configuration
- Configured `hijack_netrw_behavior = "open_default"` so opening directories opens the left Neo-tree sidebar instead of netrw/full-window buffer.
- Added `VimEnter` autocommand to automatically open the Neo-tree sidebar on startup when opening directory paths or starting with an empty buffer, preserving seamless preview capabilities (`P`).

### Added — Claude Code Configuration
- Unified global [CLAUDE.md](file:///home/alexander/Github/terminal-configs/claude-code/CLAUDE.md) incorporating the MSTSPAT (Minimal, Self-documenting, Type-exact, Secure, Performant, Accessible, and Testable) code quality standard, mandatory `<thinking>` planning tags, Stack Preferences (TypeScript/Next.js/bun, Python/uv), and Pacific Time timezone settings.
- Integrated custom Claude Code slash commands [plan.md](file:///home/alexander/Github/terminal-configs/claude-code/commands/plan.md), [cook.md](file:///home/alexander/Github/terminal-configs/claude-code/commands/cook.md), [continue.md](file:///home/alexander/Github/terminal-configs/claude-code/commands/continue.md), and [release.md](file:///home/alexander/Github/terminal-configs/claude-code/commands/release.md) under `claude-code/commands/`.
- Updated [install.sh](file:///home/alexander/Github/terminal-configs/install.sh) and [bin/mac-bootstrap.sh](file:///home/alexander/Github/terminal-configs/bin/mac-bootstrap.sh) to automatically symlink CLAUDE.md and the commands to `~/.claude/` and `~/.claude/commands/`, with safe timestamped backup rotation for pre-existing configurations.

### Added — `.tmux.conf`
- `default-terminal "tmux-256color"` + `terminal-overrides` for true 24-bit color inside tmux
- `escape-time 0` to eliminate the 500ms ESC delay (fixes sluggish input in neovim)
- `focus-events on` so neovim receives focus/blur signals (enables autoread, statusline updates)
- `history-limit 50000` — 25× larger scrollback buffer (was 2000)
- `base-index 1` and `pane-base-index 1` — windows and panes now number from 1
- `renumber-windows on` — windows auto-renumber after one is closed, no more index gaps

### Fixed — `.tmux.conf`
- `ctrl+tab` / `ctrl+shift+tab` previously called `select-pane -t :.+` / `select-pane -t :.-`,
  which cycles panes within a window. Corrected to `next-window` / `previous-window` so the
  keybinds actually cycle through tmux windows as intended.

### Changed — `.tmux.conf`
- Removed duplicate `set -g mouse on` line (was declared twice)

### Fixed — `.config/ghostty/config`
- `ctrl+tab` and `ctrl+shift+tab` were bound to `unbind`, causing the keys to fall through as
  literal tab input. Changed to send custom escape sequences (`\x1b[27;5;9~` /
  `\x1b[27;6;9~`) that tmux picks up via `user-keys` and maps to window navigation.

### Changed — `.config/ghostty/config`
- `macos-titlebar-style`: `tabs` → `hidden` for a cleaner, borderless window frame

---

## [0.6.0] — 2026-05-XX

### Added
- Migrated to GNU Stow and added `bin/` bootstrap infrastructure

## [0.5.0] — 2026-05-XX

### Fixed
- Used `tmux new-session -A` in ghostty launch command to prevent duplicate session errors

## [0.4.0] — 2026-05-XX

### Added
- Synced Brewfile and `install.sh` with current system state

## [0.3.0] — 2026-05-XX

### Added
- Replaced ghostty config with full hardened production profile

## [0.2.0] — 2026-05-XX

### Added
- `.gitconfig`, `.zprofile`, and Karabiner config

## [0.1.0] — 2026-05-XX

### Added
- Initial commit: terminal configurations and dotfiles
- Brewfile and setup script for package restoration
