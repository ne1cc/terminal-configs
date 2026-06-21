# tmux Configurations History & Evolution

This document contains a compilation of the tmux configuration (`.tmux.conf`) files created and modified over time.

---

## 1. Current Active Configuration (`.tmux.conf`)

This is the current configuration in your workspace directory: [`.tmux.conf`](file:///Users/alexandersun/Github/terminal-configs/.tmux.conf).

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

# Press Prefix + J to interactively choose a window/pane to join into the current window
bind-key J choose-tree -G "join-pane -h -s '%%'"

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

# Break pane out into a new window (prefix + B)
bind B break-pane

# Pull all panes from a specified window (prefix + Alt + j)
bind -r M-j command-prompt -p "Pull all panes from window:" "run-shell 'for p in \$(tmux list-panes -t :%% -F \"#D\"); do tmux join-pane -s \$p; done; tmux select-layout tiled'"

# Push all panes of this window to another window (prefix + Alt + m)
bind -r M-m command-prompt -p "Push all panes to window:" "run-shell 'current_pane=\$(tmux display-message -p \"#D\"); for p in \$(tmux list-panes -F \"#D\"); do [ \"\$p\" != \"\$current_pane\" ] && tmux join-pane -s \$p -t :%%; done; tmux join-pane -s \$current_pane -t :%%; tmux select-layout -t :%% tiled'"
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
