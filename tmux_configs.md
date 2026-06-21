# tmux Configurations History & Evolution

This document contains a compilation of the tmux configuration (`.tmux.conf`) files created and modified over time.

---

## 1. Current Active Configuration (`.tmux.conf`)

This is the current configuration in your workspace directory: [`.tmux.conf`](file:///Users/alexandersun/Github/terminal-configs/.tmux.conf).

```tmux
# ==============================================================================
# TMUX CONFIGURATION
# Optimized for Alacritty + Neovim + Tokyo Night palette
# Managed via GNU Stow: ~/Terminal-configs → $HOME
# ==============================================================================

# ==============================================================================
# PREFIX
# ==============================================================================
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix


# ==============================================================================
# TERMINAL & COLOR SUPPORT
# ==============================================================================

# tmux-256color is correct inside tmux; Alacritty handles the outer terminal.
set -g default-terminal "tmux-256color"

# Enable true 24-bit color pass-through for both xterm-style and alacritty terminals.
set -ga terminal-overrides ",xterm-256color:Tc"
set -as terminal-features ",alacritty:24bit"

# Remove ESC delay (critical for neovim mode switching)
set -sg escape-time 0

# Pass focus events to panes (needed for neovim autoread / gitsigns refresh)
set -g focus-events on

# Extended key protocol — lets tmux request XTerm modifyOtherKeys from Alacritty
# so Ctrl+Tab, Ctrl+Shift+Tab etc. are reported as C-Tab / C-BTab natively.
set -g extended-keys on


# ==============================================================================
# GENERAL BEHAVIOR
# ==============================================================================

set -g history-limit 50000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on
set -g mouse on
set -g mode-keys vi

# Aggressive resize: fit to the smallest attached client only when multiple
# clients are actually looking at the same window.
setw -g aggressive-resize on

# Press Prefix + J to interactively choose a window/pane to join into the current window
bind-key J choose-tree -G "join-pane -h -s '%%'"

# Activity alerts in background windows
set -g monitor-activity on
set -g visual-activity off

# Easy config reload
bind-key r source-file ~/.tmux.conf \; display-message "✓ ~/.tmux.conf reloaded"


# ==============================================================================
# STATUS BAR — Tokyo Night palette, pinned to top to mimic IDE tab bar
# Mirrors Alacritty background #1a1b26 so the bar bleeds seamlessly into
# the window chrome / titlebar area.
# ==============================================================================

set -g status on
set -g status-position top
set -g status-interval 5
set -g status-style "bg=#1a1b26,fg=#a9b1d6"

# --- Left: session name ---
# --- Left: session name ---
set -g status-left-length 40
set -g status-left "#[bg=#7dcfff,fg=#1a1b26,bold] #S #[bg=#1a1b26,fg=#7dcfff] "

# --- Window list (center) ---
set -g status-justify left
setw -g window-status-format         "#[fg=#565f89] #I:#W#{?window_flags,#{window_flags}, } "
# --- Window list (center) ---
set -g status-justify left
setw -g window-status-format         "#[fg=#565f89] #I:#W#{?window_flags,#{window_flags}, } "
setw -g window-status-current-format "#[bg=#2d3149,fg=#7dcfff,bold] #I:#W#{?window_flags,#{window_flags}, } "
setw -g window-status-activity-style "fg=#e0af68"

# --- Right: host · date · time ---
set -g status-right-length 80
set -g status-right "#[fg=#565f89]#H  #[fg=#a9b1d6]%a %b %d  #[fg=#7dcfff,bold]%H:%M "

# --- Pane borders (Tokyo Night) ---
set -g pane-border-style        "fg=#32344a"
set -g pane-active-border-style "fg=#7dcfff"
set -g pane-border-status top
set -g pane-border-format "#{pane_index}: #{pane_title}"

# --- Message / command line ---
set -g message-style       "bg=#2d3149,fg=#7dcfff"
set -g message-command-style "bg=#2d3149,fg=#bb9af7"

# --- Copy mode highlight ---
set -g mode-style "bg=#2d3149,fg=#c0caf5"


# ==============================================================================
# COPY MODE (vi)
# ==============================================================================

bind-key -T copy-mode-vi v         send-keys -X begin-selection
bind-key -T copy-mode-vi C-v       send-keys -X rectangle-toggle
bind-key -T copy-mode-vi Escape    send-keys -X cancel

# Copy + confirmation toast. copy-pipe-and-cancel pushes the selection to the
# system clipboard (xclip → xsel → pbcopy fallback), then display-message shows
# a brief "copied" popup in the status line with the byte count.
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard 2>/dev/null || xsel --clipboard --input 2>/dev/null || pbcopy" \; display-message "✓ Copied #{buffer_size} bytes to clipboard"

# Mouse drag release → auto-copy on select (restores Ghostty copy-on-select)
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard 2>/dev/null || xsel --clipboard --input 2>/dev/null || pbcopy" \; display-message "✓ Copied #{buffer_size} bytes to clipboard"

# How long the "copied" toast (and other messages) stays visible
set -g display-time 1200

# Quick copy-mode entry
bind-key Enter copy-mode


# ==============================================================================
# SPLITS & WINDOWS
# ==============================================================================

# Intuitive split shortcuts — always inherit current pane's working directory
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# Vim-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Ctrl+Tab / Ctrl+Shift+Tab → cycle panes
# Requires extended-keys on (above). Alacritty keyboard.bindings also explicitly
# sends [27;5;9~ / [27;6;9~ as a belt-and-suspenders guarantee.
bind-key -n C-Tab  select-pane -t :.+
bind-key -n C-BTab select-pane -t :.-

# Arrow keys: physically swap/move panes in that direction
bind Left  swap-pane -d -t '{left}'
bind Down  swap-pane -d -t '{down}'
bind Up    swap-pane -d -t '{up}'
bind Right swap-pane -d -t '{right}'

# Resize panes with Prefix + Shift+hjkl (5-cell steps)
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Zoom toggle shortcut (mirrors typical IDE "maximize pane")
bind z resize-pane -Z

# Move current pane to the next window
bind-key > join-pane -t :+

# Move current pane to the previous window (for symmetry)
bind-key < join-pane -t :-

# Last-window fast toggle
bind-key \` last-window

# Toggle status bar visibility
bind-key b set-option status


# ==============================================================================
# PANE / WINDOW MANAGEMENT
# ==============================================================================

# Prefix + g → "grab": interactively choose a pane to join into current window
# (moved off 'j' so 'j' stays free for select-pane -D / vim-style down navigation)
bind-key g choose-tree -G "join-pane -h -s '%%'"

# Prefix + S → prompt for source window number to join (vertical split)
bind-key S command-prompt -p "Join pane from window:" "join-pane -h -s ':%%'"

# Prefix + W → high-information tree with process names, PIDs, last activity
bind-key W choose-tree -Z -F "#{?pane_format,#[fg=cyan]Pane #P: #[fg=white]#[bold]#{pane_current_command} #[fg=yellow][PID #D] #[fg=green](Access: #{t/p:pane_last_activity}) #{?pane_active,#[fg=red][ACTIVE],},#[fg=magenta]Window #I #W #{?window_activity_flag,#[fg=red][ALERT: NEW OUTPUT],}}"

# Prefix + M → Join marked pane horizontally into current window
bind-key M join-pane -h -s '{marked}'

# Prefix + R → rename current pane title
bind-key R command-prompt -p "Rename pane:" "select-pane -T '%%'"

# Kill pane/window without confirmation prompt
bind-key x kill-pane
bind-key X kill-window

# Toggle pane synchronization
bind-key y set-window-option synchronize-panes \; display-message "Panes #{?synchronize-panes,SYNCHRONIZED,DE-SYNCHRONIZED}"

# Break pane out into a new window (prefix + B)
bind-key B break-pane

# Break active pane to background window (prefix + Alt + Shift + B / M-B)
bind-key M-B break-pane -d

# Promote all other panes in the current window to background windows (prefix + Alt + b / M-b)
bind-key M-b run-shell 'current_pane=$(tmux display-message -p "#D"); for p in $(tmux list-panes -F "#D"); do [ "$p" != "$current_pane" ] && tmux break-pane -d -s $p; done'

# Pull all panes from a specified window (prefix + Alt + j / M-j)
bind-key -r M-j command-prompt -p "Pull all panes from window:" "run-shell 'for p in \$(tmux list-panes -t :%% -F \"#D\"); do tmux join-pane -s \$p; done; tmux select-layout tiled'"

# Push all panes of this window to another window (prefix + Alt + m / M-m)
bind-key -r M-m command-prompt -p "Push all panes to window:" "run-shell 'current_pane=\$(tmux display-message -p \"#D\"); for p in \$(tmux list-panes -F \"#D\"); do [ \"\$p\" != \"\$current_pane\" ] && tmux join-pane -s \$p -t :%%; done; tmux join-pane -s \$current_pane -t :%%; tmux select-layout -t :%% tiled'"

# Toggle pane borders visibility (moved from B to Ctrl-b because B is now break-pane)
bind-key C-b set-option -g pane-border-status \; display-message "Pane borders #{?pane-border-status,ENABLED,DISABLED}"

# Centered git status popup
bind-key C-g display-popup -d "#{pane_current_path}" -E -w 85% -h 85% "git status; echo; echo 'Press Enter to close...'; read"


# ==============================================================================
# SESSION MANAGEMENT & AUTOMATION
# ==============================================================================

# Prefix + N → new named session
bind-key N command-prompt -p "New session name:" "new-session -s '%%'"

# ==============================================================================
# GIT WORKTREE + CLAUDE SESSION WORKFLOW
# ==============================================================================

# Prefix + C-n → prompt for branch, create worktree sibling dir, open new window with claude
bind-key C-n command-prompt -p "New worktree branch:" \
  "new-window -c '#{pane_current_path}' -n '%1' 'zsh -ic \"wt-new %1; exec zsh\"'"

# Prefix + C-a → fzf-pick existing worktree in a popup → opens new window with claude
bind-key C-a display-popup -E -w 70% -h 50% "zsh -ic 'wt-tmux-attach'"

# Prefix + C-x → fzf-pick a worktree to remove (removes dir + deletes branch)
bind-key C-x display-popup -E -w 70% -h 50% "zsh -ic 'wt-rm'"

# Prefix + a → Open or re-attach to a persistent centered Claude popup session
bind-key a display-popup -d "#{pane_current_path}" -E -w 85% -h 85% "tmux attach-session -t claude-popup || tmux new-session -s claude-popup 'claude'"

# Prefix + A → Open a side-by-side pane running Claude (35% width split)
bind-key A split-window -h -l 35% -c "#{pane_current_path}" "claude"

# Prefix + F → Fuzzy-find a file name and copy its path to the system clipboard
bind-key F display-popup -d "#{pane_current_path}" -E -w 75% -h 60% "zsh -c 'file=\$(fzf) && [ -n \"\$file\" ] && (echo -n \"\$file\" | xclip -selection clipboard 2>/dev/null || echo -n \"\$file\" | xsel --clipboard --input 2>/dev/null || echo -n \"\$file\" | pbcopy) && tmux display-message \"✓ Copied \$file to clipboard\"'"

# Prefix + d → detach (default), but also keep a "detach all others" binding
bind-key D detach-client -a

# Prefix + $ → rename current session
bind-key '$' command-prompt -p "Rename session:" "rename-session '%%'"

# Kill all panes except the current one
bind -r G kill-pane -a

# Post-Prod Archive: Capture pane history and save to a timestamped log file
bind-key P \
    capture-pane -S -30000 \; \
    save-buffer "${HOME}/tmux_archive_#{session_name}_%Y%m%d_%H%M%S.log" \; \
    delete-buffer \; \
    display-message "Pane history archived to ~/tmux_archive_#{session_name}_*.log"


# ==============================================================================
# AUTOMATIC PANE LOGGING — always-on, every pane
# ==============================================================================
# Every pane streams a full copy of its output to ~/tmux-logs from the moment
# it is created. pipe-pane format-expands #{...} against the target pane, while
# $(date ...) is evaluated once by the shell when the pipe opens, so each file
# name encodes session-window.pane + a creation timestamp and never collides.
# The -o flag makes this idempotent: a pane that is already being piped is left
# alone, so re-sourcing this config or resurrect/continuum restores won't create
# duplicate pipes. Logs are append (>>) so a re-attached pane keeps one file.
#
# This complements (does not replace) the manual prefix+P archive above and the
# tmux-logging plugin's on-demand captures below.
set-hook -g after-new-session  'pipe-pane -o "mkdir -p ~/tmux-logs && cat >> ~/tmux-logs/auto-#{session_name}-#{window_index}.#{pane_index}-$(date +%Y%m%dT%H%M%S).log"'
set-hook -g after-new-window   'pipe-pane -o "mkdir -p ~/tmux-logs && cat >> ~/tmux-logs/auto-#{session_name}-#{window_index}.#{pane_index}-$(date +%Y%m%dT%H%M%S).log"'
set-hook -g after-split-window 'pipe-pane -o "mkdir -p ~/tmux-logs && cat >> ~/tmux-logs/auto-#{session_name}-#{window_index}.#{pane_index}-$(date +%Y%m%dT%H%M%S).log"'


# ==============================================================================
# TPM PLUGIN CONFIGURATION
# ==============================================================================

# Core Plugin Repository Setup
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-logging'

# Resurrect Engine Adjustments
set -g @tmux-resurrect-capture-pane-contents 'on'
set -g @tmux-resurrect-processes 'ssh psql mysql sqlite3 tail top htop'

# Auto-Restore Settings
set -g @tmux-continuum-restore 'on'

# tmux-logging — on-demand manual captures, all written to ~/tmux-logs.
# Toggle key is moved off its default 'P' (which our archive binding owns) to
# Alt-l, grouping it with the plugin's other Alt-based manual commands:
#   prefix + M-l  → toggle continuous logging of the current pane
#   prefix + M-p  → screen-capture the visible pane contents
#   prefix + M-P  → save the complete scrollback history
#   prefix + M-c  → clear the current pane's history
set -g @logging_key 'M-l'
set -g @logging-path             "$HOME/tmux-logs"
set -g @screen-capture-path      "$HOME/tmux-logs"
set -g @save-complete-history-path "$HOME/tmux-logs"

# Initialize TMUX plugin manager (Must remain the absolute final line of this file)
run '~/.tmux/plugins/tpm/tpm'
```


---

## 2. Commit History and Revisions

Below is the chronological evolution of `.tmux.conf` from the initial commit to the current state.

### Commit 9: `b645cac` (Current / Latest)
**Message**: `fix: add mode-keys vi so copy mode scrolling works`
* **Changes**: Adds `set -g mode-keys vi` and configures custom selection/copying keybindings in copy-mode to interact with the macOS clipboard via `pbcopy`.

```tmux
# Change leader key prefix to Ctrl+Space
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# Terminal and color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Remove ESC delay (critical for neovim)
set -sg escape-time 0

# Pass focus events to panes (needed for neovim autoread)
set -g focus-events on

# Larger scrollback and saner defaults
set -g history-limit 50000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on

# Enable mouse mode for scrolling and selecting individual panes
set -g mouse on

# Vi keys in copy mode
set -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
bind-key -T copy-mode-vi Escape send-keys -X cancel
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# Press Prefix + j to interactively choose a window/pane to join into the current window
bind-key j choose-tree -G "join-pane -h -s '%%'"

# Press Prefix + s to prompt cleanly for just the source window number (vertical split)
bind-key S command-prompt -p "Join pane from window:" "join-pane -h -s ':%%'"

# Enable pane status borders and formatting for custom pane renaming
set -g pane-border-status top
set -g pane-border-format "#{pane_index}: #{pane_title}"

# High-Information Monitoring Layout with Process Names Restored
bind-key W choose-tree -Z -F "#{?pane_format,#[fg=cyan]Pane #P: #[fg=white]#[bold]#{pane_current_command} #[fg=yellow][PID #D] #[fg=green](Access: #{t/p:pane_last_activity}) #{?pane_active,#[fg=red][ACTIVE],},#[fg=magenta]Window #I #W #{?window_activity_flag,#[fg=red][ALERT: NEW OUTPUT],}}"
bind-key M choose-tree -Z "join-pane -h -t \"%%\""

# Use Prefix + Arrow keys to physically swap/move panes in that direction
bind Left swap-pane -d -t '{left}'
bind Down swap-pane -d -t '{down}'
bind Up swap-pane -d -t '{up}'
bind Right swap-pane -d -t '{right}'

# Ctrl+Tab / Ctrl+Shift+Tab → cycle windows (Ghostty passes through natively as \e[27;5;9~)
bind-key -n C-Tab select-pane -t :.+
bind-key -n C-BTab select-pane -t :.-

# Vim-style pane navigation (prefix + h/j/k/l)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Intuitive split shortcuts (prefix + | and prefix + -)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# New window opens in same directory
bind c new-window -c "#{pane_current_path}"
```

---

### Commit 8: `884eb14`
**Message**: `fix: ctrl+tab cycles panes not windows`
* **Changes**: Replaced `next-window`/`previous-window` commands for `C-Tab`/`C-BTab` with pane-cycling commands `select-pane -t :.+` and `select-pane -t :.-` respectively.

```tmux
# Change leader key prefix to Ctrl+Space
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# Terminal and color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Remove ESC delay (critical for neovim)
set -sg escape-time 0

# Pass focus events to panes (needed for neovim autoread)
set -g focus-events on

# Larger scrollback and saner defaults
set -g history-limit 50000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on

# Enable mouse mode for scrolling and selecting individual panes
set -g mouse on

# Send mouse selections straight to the macOS system clipboard
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# Press Prefix + j to interactively choose a window/pane to join into the current window
bind-key j choose-tree -G "join-pane -h -s '%%'"

# Press Prefix + s to prompt cleanly for just the source window number (vertical split)
bind-key S command-prompt -p "Join pane from window:" "join-pane -h -s ':%%'"

# Enable pane status borders and formatting for custom pane renaming
set -g pane-border-status top
set -g pane-border-format "#{pane_index}: #{pane_title}"

# High-Information Monitoring Layout with Process Names Restored
bind-key W choose-tree -Z -F "#{?pane_format,#[fg=cyan]Pane #P: #[fg=white]#[bold]#{pane_current_command} #[fg=yellow][PID #D] #[fg=green](Access: #{t/p:pane_last_activity}) #{?pane_active,#[fg=red][ACTIVE],},#[fg=magenta]Window #I #W #{?window_activity_flag,#[fg=red][ALERT: NEW OUTPUT],}}"
bind-key M choose-tree -Z "join-pane -h -t \"%%\""

# Use Prefix + Arrow keys to physically swap/move panes in that direction
bind Left swap-pane -d -t '{left}'
bind Down swap-pane -d -t '{down}'
bind Up swap-pane -d -t '{up}'
bind Right swap-pane -d -t '{right}'

# Ctrl+Tab / Ctrl+Shift+Tab → cycle windows (Ghostty passes through natively as \e[27;5;9~)
bind-key -n C-Tab select-pane -t :.+
bind-key -n C-BTab select-pane -t :.-

# Vim-style pane navigation (prefix + h/j/k/l)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Intuitive split shortcuts (prefix + | and prefix + -)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# New window opens in same directory
bind c new-window -c "#{pane_current_path}"
```

---

### Commit 7: `bf59f68`
**Message**: `fix: use esc: action and C-Tab bind for ctrl+tab window switching`
* **Changes**: Switched back to binding directly to `C-Tab` and `C-BTab` without the helper `user-keys` variable, as tmux 3.3+ decodes native `\e[27;5;9~` correctly.

```tmux
# Change leader key prefix to Ctrl+Space
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# Terminal and color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Remove ESC delay (critical for neovim)
set -sg escape-time 0

# Pass focus events to panes (needed for neovim autoread)
set -g focus-events on

# Larger scrollback and saner defaults
set -g history-limit 50000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on

# Enable mouse mode for scrolling and selecting individual panes
set -g mouse on

# Send mouse selections straight to the macOS system clipboard
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# Press Prefix + j to interactively choose a window/pane to join into the current window
bind-key j choose-tree -G "join-pane -h -s '%%'"

# Press Prefix + s to prompt cleanly for just the source window number (vertical split)
bind-key S command-prompt -p "Join pane from window:" "join-pane -h -s ':%%'"

# Enable pane status borders and formatting for custom pane renaming
set -g pane-border-status top
set -g pane-border-format "#{pane_index}: #{pane_title}"

# High-Information Monitoring Layout with Process Names Restored
bind-key W choose-tree -Z -F "#{?pane_format,#[fg=cyan]Pane #P: #[fg=white]#[bold]#{pane_current_command} #[fg=yellow][PID #D] #[fg=green](Access: #{t/p:pane_last_activity}) #{?pane_active,#[fg=red][ACTIVE],},#[fg=magenta]Window #I #W #{?window_activity_flag,#[fg=red][ALERT: NEW OUTPUT],}}"
bind-key M choose-tree -Z "join-pane -h -t \"%%\""

# Use Prefix + Arrow keys to physically swap/move panes in that direction
bind Left swap-pane -d -t '{left}'
bind Down swap-pane -d -t '{down}'
bind Up swap-pane -d -t '{up}'
bind Right swap-pane -d -t '{right}'

# Ctrl+Tab / Ctrl+Shift+Tab → cycle windows (Ghostty passes through natively as \e[27;5;9~)
bind-key -n C-Tab next-window
bind-key -n C-BTab previous-window

# Vim-style pane navigation (prefix + h/j/k/l)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Intuitive split shortcuts (prefix + | and prefix + -)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# New window opens in same directory
bind c new-window -c "#{pane_current_path}"
```

---

### Commit 6: `3e28bf1`
**Message**: `fix: revert to text: with private sequence \e[1001~ for ctrl+tab`
* **Changes**: Reverted the ctrl+tab method to `user-keys` utilizing the private escape sequence.

```tmux
# Change leader key prefix to Ctrl+Space
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# Terminal and color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Remove ESC delay (critical for neovim)
set -sg escape-time 0

# Pass focus events to panes (needed for neovim autoread)
set -g focus-events on

# Larger scrollback and saner defaults
set -g history-limit 50000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on

# Enable mouse mode for scrolling and selecting individual panes
set -g mouse on

# Send mouse selections straight to the macOS system clipboard
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# Press Prefix + j to interactively choose a window/pane to join into the current window
bind-key j choose-tree -G "join-pane -h -s '%%'"

# Press Prefix + s to prompt cleanly for just the source window number (vertical split)
bind-key S command-prompt -p "Join pane from window:" "join-pane -h -s ':%%'"

# Enable pane status borders and formatting for custom pane renaming
set -g pane-border-status top
set -g pane-border-format "#{pane_index}: #{pane_title}"

# High-Information Monitoring Layout with Process Names Restored
bind-key W choose-tree -Z -F "#{?pane_format,#[fg=cyan]Pane #P: #[fg=white]#[bold]#{pane_current_command} #[fg=yellow][PID #D] #[fg=green](Access: #{t/p:pane_last_activity}) #{?pane_active,#[fg=red][ACTIVE],},#[fg=magenta]Window #I #W #{?window_activity_flag,#[fg=red][ALERT: NEW OUTPUT],}}"
bind-key M choose-tree -Z "join-pane -h -t \"%%\""

# Use Prefix + Arrow keys to physically swap/move panes in that direction
bind Left swap-pane -d -t '{left}'
bind Down swap-pane -d -t '{down}'
bind Up swap-pane -d -t '{up}'
bind Right swap-pane -d -t '{right}'

# Ctrl+Tab / Ctrl+Shift+Tab → cycle windows (Ghostty passes through natively as \e[27;5;9~)
set -s user-keys[0] "\e[1001~"
bind-key -n User0 next-window

set -s user-keys[1] "\e[1002~"
bind-key -n User1 previous-window

# Vim-style pane navigation (prefix + h/j/k/l)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Intuitive split shortcuts (prefix + | and prefix + -)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# New window opens in same directory
bind c new-window -c "#{pane_current_path}"
```

---

### Commit 5: `d200029`
**Message**: `fix: restore working ctrl+tab approach from initial commit`
* **Changes**: Switched to mapping Ghostty passthrough to custom `select-window -t :+1` and `select-window -t :-1`.

```tmux
# Change leader key prefix to Ctrl+Space
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# Terminal and color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Remove ESC delay (critical for neovim)
set -sg escape-time 0

# Pass focus events to panes (needed for neovim autoread)
set -g focus-events on

# Larger scrollback and saner defaults
set -g history-limit 50000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on

# Enable mouse mode for scrolling and selecting individual panes
set -g mouse on

# Send mouse selections straight to the macOS system clipboard
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# Press Prefix + j to interactively choose a window/pane to join into the current window
bind-key j choose-tree -G "join-pane -h -s '%%'"

# Press Prefix + s to prompt cleanly for just the source window number (vertical split)
bind-key S command-prompt -p "Join pane from window:" "join-pane -h -s ':%%'"

# Enable pane status borders and formatting for custom pane renaming
set -g pane-border-status top
set -g pane-border-format "#{pane_index}: #{pane_title}"

# High-Information Monitoring Layout with Process Names Restored
bind-key W choose-tree -Z -F "#{?pane_format,#[fg=cyan]Pane #P: #[fg=white]#[bold]#{pane_current_command} #[fg=yellow][PID #D] #[fg=green](Access: #{t/p:pane_last_activity}) #{?pane_active,#[fg=red][ACTIVE],},#[fg=magenta]Window #I #W #{?window_activity_flag,#[fg=red][ALERT: NEW OUTPUT],}}"
bind-key M choose-tree -Z "join-pane -h -t \"%%\""

# Use Prefix + Arrow keys to physically swap/move panes in that direction
bind Left swap-pane -d -t '{left}'
bind Down swap-pane -d -t '{down}'
bind Up swap-pane -d -t '{up}'
bind Right swap-pane -d -t '{right}'

# Ctrl+Tab / Ctrl+Shift+Tab → cycle windows (Ghostty passes through natively as \e[27;5;9~)
set -s user-keys[0] "\e[27;5;9~"
bind-key -n User0 select-window -t :+1

set -s user-keys[1] "\e[27;6;9~"
bind-key -n User1 select-window -t :-1

# Vim-style pane navigation (prefix + h/j/k/l)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Intuitive split shortcuts (prefix + | and prefix + -)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# New window opens in same directory
bind c new-window -c "#{pane_current_path}"
```

---

### Commit 4: `85a2d1b`
**Message**: `fix: use private CSI sequences for ctrl+tab window navigation`
* **Changes**: Implemented private CSI sequences `\e[1001~` and `\e[1002~` to map Ctrl+Tab and Ctrl+Shift+Tab without interference from tmux's internal extended key parser.

```tmux
# Change leader key prefix to Ctrl+Space
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# Terminal and color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Remove ESC delay (critical for neovim)
set -sg escape-time 0

# Pass focus events to panes (needed for neovim autoread)
set -g focus-events on

# Larger scrollback and saner defaults
set -g history-limit 50000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on

# Enable mouse mode for scrolling and selecting individual panes
set -g mouse on

# Send mouse selections straight to the macOS system clipboard
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# Press Prefix + j to interactively choose a window/pane to join into the current window
bind-key j choose-tree -G "join-pane -h -s '%%'"

# Press Prefix + s to prompt cleanly for just the source window number (vertical split)
bind-key S command-prompt -p "Join pane from window:" "join-pane -h -s ':%%'"

# Enable pane status borders and formatting for custom pane renaming
set -g pane-border-status top
set -g pane-border-format "#{pane_index}: #{pane_title}"

# High-Information Monitoring Layout with Process Names Restored
bind-key W choose-tree -Z -F "#{?pane_format,#[fg=cyan]Pane #P: #[fg=white]#[bold]#{pane_current_command} #[fg=yellow][PID #D] #[fg=green](Access: #{t/p:pane_last_activity}) #{?pane_active,#[fg=red][ACTIVE],},#[fg=magenta]Window #I #W #{?window_activity_flag,#[fg=red][ALERT: NEW OUTPUT],}}"
bind-key M choose-tree -Z "join-pane -h -t \"%%\""

# Use Prefix + Arrow keys to physically swap/move panes in that direction
bind Left swap-pane -d -t '{left}'
bind Down swap-pane -d -t '{down}'
bind Up swap-pane -d -t '{up}'
bind Right swap-pane -d -t '{right}'

# Ctrl+Tab / Ctrl+Shift+Tab → cycle windows
# Private CSI sequences bypass tmux's extended-key parser (unlike \e[27;5;9~)
set -s user-keys[0] "\e[1001~"
bind-key -n User0 next-window
set -s user-keys[1] "\e[1002~"
bind-key -n User1 previous-window

# Vim-style pane navigation (prefix + h/j/k/l)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Intuitive split shortcuts (prefix + | and prefix + -)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# New window opens in same directory
bind c new-window -c "#{pane_current_path}"
```

---

### Commit 3: `2ee61c0`
**Message**: `fix: switch ctrl+tab routing to F13/F14 and drop ghostty splits`
* **Changes**: Switched to mapping F13/F14 keys for cycling windows, added intuitive directory-inheriting split keybinds (`|` and `-`), vim-style pane navigation (`h/j/k/l`), and overriding `c` (new window) to open in the current directory.

```tmux
# Change leader key prefix to Ctrl+Space
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# Terminal and color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Remove ESC delay (critical for neovim)
set -sg escape-time 0

# Pass focus events to panes (needed for neovim autoread)
set -g focus-events on

# Larger scrollback and saner defaults
set -g history-limit 50000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on

# Enable mouse mode for scrolling and selecting individual panes
set -g mouse on

# Send mouse selections straight to the macOS system clipboard
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# Press Prefix + j to interactively choose a window/pane to join into the current window
bind-key j choose-tree -G "join-pane -h -s '%%'"

# Press Prefix + s to prompt cleanly for just the source window number (vertical split)
bind-key S command-prompt -p "Join pane from window:" "join-pane -h -s ':%%'"

# Enable pane status borders and formatting for custom pane renaming
set -g pane-border-status top
set -g pane-border-format "#{pane_index}: #{pane_title}"

# High-Information Monitoring Layout with Process Names Restored
bind-key W choose-tree -Z -F "#{?pane_format,#[fg=cyan]Pane #P: #[fg=white]#[bold]#{pane_current_command} #[fg=yellow][PID #D] #[fg=green](Access: #{t/p:pane_last_activity}) #{?pane_active,#[fg=red][ACTIVE],},#[fg=magenta]Window #I #W #{?window_activity_flag,#[fg=red][ALERT: NEW OUTPUT],}}"
bind-key M choose-tree -Z "join-pane -h -t \"%%\""

# Use Prefix + Arrow keys to physically swap/move panes in that direction
bind Left swap-pane -d -t '{left}'
bind Down swap-pane -d -t '{down}'
bind Up swap-pane -d -t '{up}'
bind Right swap-pane -d -t '{right}'

# Ctrl+Tab / Ctrl+Shift+Tab → cycle windows (Ghostty sends F13/F14 sequences)
bind-key -n F13 next-window
bind-key -n F14 previous-window

# Vim-style pane navigation (prefix + h/j/k/l)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Intuitive split shortcuts (prefix + | and prefix + -)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# New window opens in same directory
bind c new-window -c "#{pane_current_path}"
```

---

### Commit 2: `9a750e4`
**Message**: `fix(tmux+ghostty): wire ctrl+tab to window navigation and harden tmux defaults`
* **Changes**: Hardened tmux defaults (escape-time 0, focus-events on, terminal colors/overrides, history-limit 50000) and wired up initial Custom User keys logic for Ghostty.

```tmux
# Change leader key prefix to Ctrl+Space
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# Terminal and color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# Remove ESC delay (critical for neovim)
set -sg escape-time 0

# Pass focus events to panes (needed for neovim autoread)
set -g focus-events on

# Larger scrollback and saner defaults
set -g history-limit 50000
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on

# Enable mouse mode for scrolling and selecting individual panes
set -g mouse on

# Send mouse selections straight to the macOS system clipboard
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# Press Prefix + j to interactively choose a window/pane to join into the current window
bind-key j choose-tree -G "join-pane -h -s '%%'"

# Press Prefix + s to prompt cleanly for just the source window number (vertical split)
bind-key S command-prompt -p "Join pane from window:" "join-pane -h -s ':%%'"

# Enable pane status borders and formatting for custom pane renaming
set -g pane-border-status top
set -g pane-border-format "#{pane_index}: #{pane_title}"

# High-Information Monitoring Layout with Process Names Restored
bind-key W choose-tree -Z -F "#{?pane_format,#[fg=cyan]Pane #P: #[fg=white]#[bold]#{pane_current_command} #[fg=yellow][PID #D] #[fg=green](Access: #{t/p:pane_last_activity}) #{?pane_active,#[fg=red][ACTIVE],},#[fg=magenta]Window #I #W #{?window_activity_flag,#[fg=red][ALERT: NEW OUTPUT],}}"
bind-key M choose-tree -Z "join-pane -h -t \"%%\""

# Use Prefix + Arrow keys to physically swap/move panes in that direction
bind Left swap-pane -d -t '{left}'
bind Down swap-pane -d -t '{down}'
bind Up swap-pane -d -t '{up}'
bind Right swap-pane -d -t '{right}'

# Bind custom escape sequences sent by Ghostty for Ctrl+Tab and Ctrl+Shift+Tab
set -s user-keys[0] "\e[27;5;9~"
bind-key -n User0 next-window

set -s user-keys[1] "\e[27;6;9~"
bind-key -n User1 previous-window
```

---

### Commit 1: `2041a80`
**Message**: `feat: initial commit of terminal configurations and dotfiles`
* **Changes**: The very first draft of your tmux config with Ctrl+Space leader key, basic mouse configurations, window joining/monitoring and user keys targeting pane switches.

```tmux
# Change leader key prefix to Ctrl+Space
set -g prefix C-Space
unbind C-b
bind C-Space send-prefix

# Enable mouse mode for scrolling and selecting individual panes
set -g mouse on

# Send mouse selections straight to the macOS system clipboard
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# Press Prefix + j to interactively choose a window/pane to join into the current window
bind-key j choose-tree -G "join-pane -h -s '%%'"

# Press Prefix + s to prompt cleanly for just the source window number (vertical split)
bind-key S command-prompt -p "Join pane from window:" "join-pane -h -s ':%%'"

# Enable pane status borders and formatting for custom pane renaming
set -g pane-border-status top
set -g pane-border-format "#{pane_index}: #{pane_title}"

# Bind Prefix + Shift + W to open an engineered, high-information debugging tree

# Fully Expanded High-Information Monitoring Layout
set -g mouse on

# High-Information Monitoring Layout with Process Names Restored
bind-key W choose-tree -Z -F "#{?pane_format,#[fg=cyan]Pane #P: #[fg=white]#[bold]#{pane_current_command} #[fg=yellow][PID #D] #[fg=green](Access: #{t/p:pane_last_activity}) #{?pane_active,#[fg=red][ACTIVE],},#[fg=magenta]Window #I #W #{?window_activity_flag,#[fg=red][ALERT: NEW OUTPUT],}}"
bind-key M choose-tree -Z "join-pane -h -t \"%%\""

# Use Prefix + Arrow keys to physically swap/move panes in that direction
bind Left swap-pane -d -t '{left}'
bind Down swap-pane -d -t '{down}'
bind Up swap-pane -d -t '{up}'
bind Right swap-pane -d -t '{right}'

# Bind custom escape sequences sent by Ghostty for Ctrl+Tab and Ctrl+Shift+Tab
set -s user-keys[0] "\e[27;5;9~"
bind-key -n User0 select-pane -t :.+

set -s user-keys[1] "\e[27;6;9~"
bind-key -n User1 select-pane -t :.-
```
