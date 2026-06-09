# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

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
