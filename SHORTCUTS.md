# 🚀 Master Terminal & Developer Workflow Cheatsheet

A complete, exhaustive, and structured reference for every shortcut, keybinding, alias, shell function, and utility across **tmux**, **Zsh**, **Neovim**, **Lazygit**, **Yazi**, **Ghostty**, **Alacritty**, and **Karabiner-Elements**.

---

## 📑 Table of Contents
1. [tmux Keybindings (Prefix: `Ctrl + Space`)](#1-tmux-keybindings-prefix-ctrl--space)
2. [Zsh Aliases, Functions & Shell Keybindings](#2-zsh-aliases-functions--shell-keybindings)
3. [Neovim Development Environment (Leader: `Space`)](#3-neovim-development-environment-leader-space)
4. [Lazygit Custom Commands & AI Workflows](#4-lazygit-custom-commands--ai-workflows)
5. [Yazi Terminal File Manager](#5-yazi-terminal-file-manager)
6. [Terminal Emulators (Ghostty & Alacritty)](#6-terminal-emulators-ghostty--alacritty)
7. [Karabiner-Elements Window Management](#7-karabiner-elements-window-management)
8. [Custom CLI Helper Binaries & Scripts](#8-custom-cli-helper-binaries--scripts)

---

## 1. tmux Keybindings (Prefix: `Ctrl + Space`)

All commands use `Ctrl + Space` as the prefix key, unless marked as **(No Prefix)**.

### A. Seamless Navigation (Vim + tmux Integration)
| Keybinding | Scope | Description |
|---|---|---|
| `Ctrl + h` | **(No Prefix)** | Focus split / pane to the left (seamless Neovim + tmux) |
| `Ctrl + j` | **(No Prefix)** | Focus split / pane down (seamless Neovim + tmux) |
| `Ctrl + k` | **(No Prefix)** | Focus split / pane up (seamless Neovim + tmux) |
| `Ctrl + l` | **(No Prefix)** | Focus split / pane to the right (seamless Neovim + tmux) |
| `Ctrl + \` | **(No Prefix)** | Jump to last-focused split / pane |
| `Ctrl + Tab` | **(No Prefix)** | Cycle forward to next pane |
| `Ctrl + Shift + Tab` | **(No Prefix)** | Cycle backward to previous pane |

### B. Window Navigation & Swapping
| Keybinding | Scope | Description |
|---|---|---|
| `Shift + Left Arrow` / `Ctrl + PageUp` / `Ctrl + Shift + h` | **(No Prefix)** | Switch to previous window |
| `Shift + Right Arrow` / `Ctrl + PageDown` / `Ctrl + Shift + l` | **(No Prefix)** | Switch to next window |
| `Ctrl + Shift + Left Arrow` | **(No Prefix)** | Swap / move active window position left in tab bar |
| `Ctrl + Shift + Right Arrow` | **(No Prefix)** | Swap / move active window position right in tab bar |
| `Prefix + \`` / `Prefix + Tab` | Prefix | **Jump to last active window** |
| `Prefix + >` | Prefix | Move active pane into the next window |
| `Prefix + <` | Prefix | Move active pane into the previous window |

### C. Splitting & Layout
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + \|` | Prefix | Split pane vertically (inherits `$PWD`) |
| `Prefix + -` | Prefix | Split pane horizontally (inherits `$PWD`) |
| `Prefix + c` | Prefix | Create new window (inherits `$PWD`) |
| `Prefix + v` | Prefix | **Smart Split**: horizontal split if widescreen, vertical if tall |
| `Prefix + z` | Prefix | **Toggle Zoom**: maximize or restore current pane |
| `Prefix + b` | Prefix | Toggle top status bar visibility |
| `Prefix + Ctrl + b` | Prefix | Toggle pane border status titles |

### D. Pane Movement, Resizing & Organization
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Shift + H` | Prefix | Resize active pane 5 cells left (repeatable) |
| `Prefix + Shift + J` | Prefix | Resize active pane 5 cells down (repeatable) |
| `Prefix + Shift + K` | Prefix | Resize active pane 5 cells up (repeatable) |
| `Prefix + Shift + L` | Prefix | Resize active pane 5 cells right (repeatable) |
| `Prefix + Left Arrow` | Prefix | Swap active pane with left pane |
| `Prefix + Down Arrow` | Prefix | Swap active pane with lower pane |
| `Prefix + Up Arrow` | Prefix | Swap active pane with upper pane |
| `Prefix + Right Arrow` | Prefix | Swap active pane with right pane |
| `Prefix + x` | Prefix | Kill active pane (instant, no confirmation) |
| `Prefix + Shift + X` | Prefix | Kill active window (instant, no confirmation) |
| `Prefix + Shift + G` | Prefix | **Kill all other panes** in the window except active pane |
| `Prefix + m` | Prefix | Mark current pane |
| `Prefix + Shift + M` | Prefix | Join marked pane into current window |
| `Prefix + g` | Prefix | **Grab / Join Panes modal**: fuzzy search & multi-select panes with `Tab`, `Enter` to join all & auto-tile |
| `Prefix + Shift + S` | Prefix | Prompt for source window number to join pane from |
| `Prefix + Shift + R` | Prefix | Rename current pane title |
| `Prefix + y` | Prefix | Toggle pane synchronization (broadcast keystrokes to all panes) |

### E. Breakout Sessions & Multi-Terminal Windows
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Shift + B` | Prefix | Break active pane out into a new foreground window |
| `Prefix + Alt + Shift + B` | Prefix | Break active pane into a **background window** (`M-B`) |
| `Prefix + Alt + p` | Prefix | **Break active pane out into a brand-new tmux session** (prompts for name, auto-switches) |
| `Prefix + Alt + w` / `Prefix + Ctrl + w` | Prefix | **Break current window out into a brand-new tmux session** (prompts for name, auto-switches) |
| `Prefix + Alt + b` | Prefix | Demote all other panes into background windows (`M-b`) |
| `Prefix + Alt + a` | Prefix | Break active pane out into a new session in **Alacritty** (`M-a`) |
| `Prefix + Alt + g` | Prefix | Break active pane out into a new session in **Ghostty** (`M-g`) |
| `Prefix + @` | Prefix | **Break current window out into a new Ghostty process & session** |
| `Prefix + Alt + j` | Prefix | Pull all panes from a chosen window into current window (`M-j`) |
| `Prefix + Alt + m` | Prefix | Push all panes from current window to another window (`M-m`) |

### F. Interactive Fuzzy Pickers & Popups
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + s` | Prefix | **Fuzzy Session Switcher** (fzf popup modal) |
| `Prefix + w` | Prefix | **Fuzzy Window Switcher** (fzf popup modal) |
| `Prefix + e` | Prefix | **Fuzzy Pane Switcher** across all sessions (fzf popup modal) |
| `Prefix + f` | Prefix | **Tmux Sessionizer**: fuzzy find git repositories and launch session |
| `Prefix + Ctrl + g` | Prefix | **Floating Lazygit Popup** (centered 90% modal) |
| `Prefix + Shift + F` | Prefix | Fuzzy find file path & copy relative path to clipboard |
| `Prefix + Shift + W` | Prefix | Detailed process tree (PID, memory, last activity) |
| `Prefix + Shift + N` | Prefix | Prompt to create new named session |
| `Prefix + $` | Prefix | Rename current session |
| `Prefix + Shift + D` | Prefix | Detach all other attached clients |
| `Prefix + r` | Prefix | Reload `~/.tmux.conf` configuration |

### G. Window Stashing (Background Scratchpads)
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Alt + s` | Prefix | **Stash Window**: move current window to background `stash` session (`M-s`) |
| `Prefix + Alt + r` | Prefix | **Retrieve Window**: fuzzy-pick stashed window and restore (`M-r`) |

### H. Git Worktrees & AI Assistant Integration
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Ctrl + n` | Prefix | Prompt branch name, create git worktree & open Claude window |
| `Prefix + Ctrl + a` | Prefix | Fuzzy-pick existing worktree and open Claude window |
| `Prefix + Ctrl + x` | Prefix | Fuzzy-pick worktree to force-remove (directory + branch) |
| `Prefix + a` | Prefix | Open/reattach persistent centered Claude popup session |
| `Prefix + Alt + y` | Prefix | Open/reattach persistent centered Antigravity YOLO popup session (`agyy`) |
| `Prefix + /` | Prefix | **Command Palette HUD**: Interactive fuzzy search to trigger ANY tmux / shell action |
| `Prefix + Shift + O` | Prefix | **Screen File & Stacktrace Jumper**: Extract file paths from screen & jump in Neovim |
| `Prefix + Alt + i` | Prefix | **Instant Scratchpad**: Centered floating note modal editing `~/notes/scratchpad.md` |
| `Prefix + Ctrl + p` | Prefix | Open/reattach project-specific Claude popup session |
| `Prefix + Shift + A` | Prefix | Open side-by-side Claude pane (35% width split) |
| `Prefix + Ctrl + c` | Prefix | Spawn new full window running Claude in `$PWD` |
| `Prefix + Ctrl + t` | Prefix | **Agent Matrix**: Interactive `fzf` modal to tile 2, 3, 4, or mixed parallel AI agents |
| `Prefix + Shift + H` | Prefix | **Session Handoff**: Auto-generate markdown handoff note with git status & diff stats |
| `Prefix + Shift + D` | Prefix | **Dev Workspace**: Instant 3-pane IDE layout (Editor 65% + server & shell 35%) |
| `Prefix + Alt + Shift + D` | Prefix | **Triage Workspace**: Instant 4-pane 2x2 grid for debugging |
| `Prefix + Ctrl + d` | Prefix | **Docker Exec Jumper**: Fuzzy select running container and drop into shell |
| `Prefix + Ctrl + h` | Prefix | **SSH Host Jumper**: Fuzzy select SSH host from config and connect |
| `Prefix + Alt + k` | Prefix | **Ports & Dev Servers**: Interactive port inspector & process killer |
| `Prefix + Alt + c` | Prefix | **Cheat Sheet & Docs HUD**: Interactive documentation query (`cheat.sh`) |
| `Prefix + Alt + e` | Prefix | **Dotfiles Config Switcher**: Fuzzy edit `.tmux.conf`, `.zshrc`, `nvim`, etc. |
| `Prefix + Shift + Y` | Prefix | **Capture Full Visible Pane**: Copy visible screen text to system clipboard |
| `Prefix + =` | Prefix | **Rebalance / Tile Panes**: Evenly tile all active panes |

### I. Copy-Mode & Clipboard
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Enter` | Prefix | Enter vi copy-mode |
| `Prefix + u` | Prefix | Enter vi copy-mode and scroll half-page up |
| `v` | Copy-Mode | Begin visual character selection |
| `V` | Copy-Mode | Begin visual line selection |
| `y` | Copy-Mode | Yank selection to system clipboard & exit copy-mode |
| `Y` | Copy-Mode | Yank entire line to system clipboard & exit copy-mode |
| `Mouse Drag` | Mouse | Auto-copies selected text to system clipboard with notification toast |

### J. Session Persistence & Logging
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Shift + S` | Prefix | Save default session state via `tmux-resurrect` |
| `Prefix + Shift + R` | Prefix | Restore default session state via `tmux-resurrect` |
| `Prefix + Ctrl + s` | Prefix | Prompt to save a **named session snapshot** |
| `Prefix + Ctrl + r` | Prefix | Interactive fuzzy picker to restore a **named session snapshot** |
| `Prefix + Shift + P` | Prefix | Dump 30,000 lines of scrollback to `~/tmux_archive_*.log` |
| `Prefix + Alt + l` | Prefix | Toggle continuous pane output logging to `~/tmux-logs/` |
| `Prefix + Alt + p` | Prefix | Take text screenshot of visible pane to `~/tmux-logs/` |
| `Prefix + Alt + Shift + P` | Prefix | Save complete scrollback buffer to `~/tmux-logs/` |
| `Prefix + Alt + c` | Prefix | Clear pane scrollback history |
| `Prefix + Shift + I` | Prefix | Install newly declared TPM plugins |
| `Prefix + Shift + U` | Prefix | Update installed TPM plugins |
| `Prefix + Alt + u` | Prefix | Clean unused TPM plugins |

---

## 2. Zsh Aliases, Functions & Shell Keybindings

### A. Antigravity AI & Ledger Tools
| Command / Alias | Action / Purpose |
|---|---|
| `agy` | Run Google Antigravity CLI |
| `agy-yolo` / `agyy` / `yolo` | Run Antigravity bypassing tool approval prompts (`--dangerously-skip-permissions`) |
| `glog` | Markdown preview of the Antigravity audit ledger (`~/.gemini_history.md`) |
| `gdiff` | Side-by-side syntax-highlighted diff of Antigravity session history |
| `agya` | Export, render, and preview the latest Antigravity session audit report |
| `agyih` | Interactive full Antigravity session audit history viewer |

### B. Git Power Moves & Daily Aliases
| Command / Alias | Action / Purpose |
|---|---|
| `groot` | Jump directly to repository root directory from any nested subfolder |
| `gundo` | Undo last commit while keeping all changes staged in index (`git reset --soft HEAD~1`) |
| `gwip` | Instant save-point commit (`wip: save point [skip ci]`, bypasses hooks) |
| `gunwip` | Undo the WIP commit safely |
| `gpristine` | Completely reset working tree and clean untracked/ignored files (`git reset --hard && git clean -dfx`) |
| `gignored` | List all ignored files in the project |
| `gauthors` | Show commit leaderboard with counts per author |
| `gb` | Interactive fzf branch switcher with commit preview |
| `gshow` | Interactive fzf commit browser with delta diff preview |
| `gs` | Concise status with branch tracking (`git status -sb`) |
| `gd` | Unstaged diff (`git diff`) |
| `gds` | Staged diff (`git diff --staged`) |
| `gc <repo>` | Clone repository (`git clone`) |
| `gco <branch>` | Checkout branch (`git checkout`) |
| `gcb <branch>` | Create and switch to branch (`git checkout -b`) |
| `gl` | Graph git log (`git log --oneline --graph --decorate -n 20`) |
| `gaa` | Stage all changes (`git add -A`) |
| `gis` | Check if inside a valid git repository |

### C. Git Worktree Workflows
| Command / Alias | Action / Purpose |
|---|---|
| `wt-new <branch>` | Create new git worktree with dedicated branch in `.worktrees/<branch>` |
| `wt-tmux-attach` | Fuzzy-pick existing worktree and switch tmux window directly to it |
| `wt-rm` | Fuzzy-pick worktree to cleanly delete worktree and associated branch |

### D. Claude Code Automation Workflows
| Command / Alias | Action / Purpose |
|---|---|
| `cco [msg]` | Automate staging, generating, and committing changes via Claude Code |
| `cinit` | Initialize Claude configuration and project memory (`CLAUDE.md`) |
| `cbug [desc]` | Run Claude Code to diagnose and fix a bug |
| `creview` | Run Claude Code review across current branch diff |
| `cplan [task]` | Generate an implementation plan with Claude Code |
| `cdoc` | Update and generate documentation with Claude Code |
| `ctest` | Run and fix test suites with Claude Code |
| `cgc` | Compact and optimize Claude session transcripts |

### E. Clipboard & Output Ergonomics
| Command / Alias | Action / Purpose |
|---|---|
| `copylast` | Instant capture and copy of previous command output (tmux pane buffer capture with zero side-effects) |
| `copylast <N>` | Copy the last `N` lines of output from the previous command |
| `copylast -a` | Copy the entire pane scrollback buffer to clipboard |
| `cbranch` | Copy current git branch name to clipboard |
| `csha` | Copy latest git commit SHA to clipboard |
| `cpath [file]` | Copy absolute path of current working directory or given file to clipboard |
| `cpfile <file>` | Copy entire contents of a file directly to system clipboard |
| `snap` | Take screenshot to `~/Pictures/Screenshots` & copy image to clipboard |

### F. Ports, Networking & Local Development
| Command / Alias | Action / Purpose |
|---|---|
| `port <num>` | Inspect listening processes on port (e.g. `port 3000`) |
| `killport <num>` | Terminate all processes listening on port (e.g. `killport 8080`) |
| `serve [port]` | Launch zero-config HTTP static file server in `$PWD` (default: 8000) |
| `myip` | Query public IP address and geo-location details via JSON API |
| `cheat <topic>` | Query terminal cheat sheets from `cheat.sh` (e.g. `cheat tar`) |

### G. Interactive FZF Superpowers
| Command / Alias | Action / Purpose |
|---|---|
| `fo` | Fuzzy find a file with syntax-highlighted `bat` preview and open in `$EDITOR` |
| `fkill` | Interactive fuzzy process killer with live arguments preview (supports multi-select with `Tab`) |
| `fdocker` | Interactive fuzzy Docker container switcher & interactive shell attach |
| `fssh` | Interactive fuzzy SSH host jumper parsed from `~/.ssh/config` |
| `handoff [topic]` | Capture git diff stats, status, and active tasks into markdown session note |
| `matrix [2|3|4]` | Spawn parallel AI agents across 2-pane, 3-pane, or 4-pane tiled tmux grid |
| `gb-clean` | Safely delete local branches already merged into default remote branch |
| `fenv` | Interactive fuzzy search across all environment variables |
| `Ctrl + R` | Interactive fuzzy shell command history search |
| `Ctrl + T` | Interactive fuzzy file picker |
| `Alt + C` | Interactive fuzzy directory navigation |

### H. Modern CLI Enhancements
| Command / Alias | Tool | Description |
|---|---|---|
| `l` / `la` | `eza` | `eza -la --icons --group-directories-first` |
| `ls` | `eza` | `eza --icons --group-directories-first` |
| `ll` | `eza` | `eza -l --icons --group-directories-first` |
| `tree` | `eza` | `eza --tree --icons` |
| `cat` | `bat` | `bat --style=header,grid,snip --theme=ansi` |
| `df` | `duf` | Disk usage and file system utilization |
| `du` | `dust` | Interactive directory disk space analyzer |
| `z <dir>` | `zoxide` | Smart directory jumper |
| `zi` | `zoxide` | Interactive fuzzy directory jumper |
| `t` / `ta` / `tl` / `tn` | `task` | Taskwarrior task management (`add`, `list`, `next`) |
| `tui` | `taskwarrior-tui` | Interactive terminal UI for Taskwarrior |
| `tdev` | `task` | Filter tasks for `project:dev` |

### I. Application Launchers & File Handlers
| Command / Alias | Action / Purpose |
|---|---|
| `lg` | Launch Lazygit in current repository |
| `lgd` | Launch Lazygit in dotfiles repository (`~/dotfiles`) |
| `mu <file.pdf>` | Open PDF in high-speed MuPDF viewer |
| `om` / `omd` / `onemarkdown` | Open Markdown file in **One Markdown** |
| `prev` / `preview` | Open file in Apple **Preview** |
| `finder` | Open current directory in macOS Finder |
| `of <file>` | Reveal file in macOS Finder (`open -R`) |
| `y` | Launch Yazi file manager (syncs terminal `$PWD` on exit) |

### J. Shell Ergonomics & Keybindings
| Shortcut / Command | Context | Description |
|---|---|---|
| `mcd <dir>` | Shell | Create directory path and immediately `cd` into it |
| `extract <file>` | Shell | Universal archive extractor (`.tar.gz`, `.zip`, `.rar`, `.7z`, `.bz2`, etc.) |
| `path` | Shell | Pretty-print `$PATH` entries one per line |
| `..` / `...` / `....` | Shell | Quick directory traversal (`cd ..`, `cd ../..`, `cd ../../..`) |
| `prettyjson` | Shell | Format JSON from stdin (`python3 -m json.tool`) |
| `headcsv` / `tailcsv` | Shell | View top / bottom 20 lines of tabular data |
| `duck` | Shell | Launch DuckDB embedded SQL engine |
| `d` / `dc` / `dps` / `dlogs` | Shell | Docker shortcuts (`docker`, `compose`, `ps`, `logs -f`) |
| `venv` | Shell | Create and activate uv Python virtual environment (`uv venv && source .venv/bin/activate`) |
| `mkpy <name>` | Shell | Bootstrap Python project template |
| `mkts <name>` | Shell | Bootstrap TypeScript project template |
| `Ctrl + A` | Input | Jump to beginning of line |
| `Ctrl + E` | Input | Jump to end of line |
| `Alt + K` / `^[k` / `\ek` | Input | **Kill / clear line** from cursor to end of line |
| `Ctrl + K` | Input (vi) | History up / previous command |
| `Ctrl + J` | Input (vi) | History down / next command |

---

## 3. Neovim Development Environment (Leader: `Space`)

### A. Window & Pane Navigation
| Keybinding | Mode | Action |
|---|---|---|
| `Ctrl + h` | Normal | Navigate to split / tmux pane left |
| `Ctrl + j` | Normal | Navigate to split / tmux pane down |
| `Ctrl + k` | Normal | Navigate to split / tmux pane up |
| `Ctrl + l` | Normal | Navigate to split / tmux pane right |
| `Ctrl + \` | Normal | Navigate to previous split / tmux pane |
| `<Leader>z` / `<C-w>z` / `<C-w>m` | Normal | **Toggle Maximize Window** |
| `]b` / `[b` | Normal | Next / Previous buffer tab |
| `<Leader>bd` | Normal | Close buffer from tabline picker |
| `<Leader>um` | Normal | Toggle buffer modifiable state / Toggle Markdown render |

### B. File Exploration & Fuzzy Find (FzfLua)
| Keybinding | Mode | Action |
|---|---|---|
| `<Leader>e` | Normal | Toggle Neo-tree file explorer sidebar |
| `<Leader>o` | Normal | Toggle focus between Neo-tree sidebar and editor |
| `<Leader>ff` | Normal | Find Files (FzfLua) |
| `<Leader>fg` | Normal | Live Grep / Ripgrep (FzfLua) |
| `<Leader>fb` | Normal | List and switch open buffers |
| `<Leader>fh` | Normal | Search Neovim help tags |
| `<Leader>fs` | Normal | Search LSP document symbols |
| `<Leader>fr` | Normal | Search LSP references |
| `Ctrl + q` | Fzf Modal | Select all items & populate quickfix list |

### C. Git & Lazygit Integration
| Keybinding | Mode | Action |
|---|---|---|
| `<Leader>gg` / `<Leader><C-g>` / `<Leader>tl` | Normal | **Toggle Floating Lazygit TUI** (`lazygit.nvim`) |
| `<Leader>gS` | Normal | Open Fugitive git status window (`:Git`) |
| `<Leader>gD` | Normal | Open Fugitive git diff window (`:Git diff`) |
| `<Leader>gB` | Normal | Open Fugitive git blame window (`:Git blame`) |
| `<Leader>gP` | Normal | Push commits via Fugitive (`:Git push`) |

### D. Markdown, Media, Images & PDFs
| Keybinding | Mode | Action |
|---|---|---|
| `<Leader>p` / `<Leader>pi` | Normal | **Paste image from clipboard** directly into Markdown (`img-clip.nvim`) |
| `<Leader>ic` | Normal | **Clear image overlays** (fixes terminal ghosting artifacts) |
| `<Leader>~` / `<Leader>ms` | Normal / Visual | **Toggle strikethrough** (`~~text~~`) |
| `<Leader>pdf` | Normal | Open PDF under cursor or companion `.pdf` file in **MuPDF** |
| `j` / `]i` | Normal (Image buffer) | View next image in folder gallery |
| `k` / `[i` | Normal (Image buffer) | View previous image in folder gallery |

### E. Neo-tree Sidebar Shortcuts
| Keybinding | Context | Action |
|---|---|---|
| `<CR>` / `o` | Neo-tree | Open file or expand directory |
| `P` | Neo-tree | Toggle floating preview of file under cursor |
| `M` | Neo-tree | Open highlighted PDF directly in **MuPDF** |

### F. Insert / Command Mode Line Editing
| Keybinding | Mode | Action |
|---|---|---|
| `Alt + K` | Insert / Command | Cut text from cursor to end of line into clipboard (`<C-o>d$`) |
| `Ctrl + K` | Insert / Command | Clear text from cursor to end of line (`<C-o>D`) |

---

## 4. Lazygit Custom Commands & AI Workflows

Available inside Lazygit (`lg` or `Prefix + Ctrl + g`):

| Key | Context | Tool Executed | Description |
|---|---|---|---|
| **`<c-a>`** (`Ctrl + A`) | `files` | **Antigravity (`agy`)** | Analyzes staged changes and generates conventional commit title & description |
| **`C`** | `files` | **Claude CLI (`claude`)** | Reviews staged diff for bugs, edge cases, and performance regressions |
| **`X`** | `localBranches` | **OpenAI Codex (`codex`)** | Analyzes branch changes to explain architectural impact |
| **`Q`** | `files` | **Qoder (`qodercli`)** | Audits staged code changes for compliance and safety |
| **`N`** | `global` | **GitHub CLI (`gh`)** | Creates GitHub Pull Request (`gh pr create --fill`) |
| **`O`** | `localBranches` | **GitHub CLI (`gh`)** | Checks out GitHub Pull Request for selected branch |
| **`<c-y>`** (`Ctrl + Y`) | `files` / `commitFiles` | Clipboard | Copies full file contents to system clipboard |
| **`Y`** (`Shift + Y`) | `files` / `commitFiles` | Clipboard | Copies git diff / patch of selected file or commit to clipboard |
| **`d`** | `commits` | Git Hard Reset | Drops selected local commit with confirmation (`git reset --hard HEAD~1`) |
| **`<alt-y>`** | `files` / `commitFiles` | `pbcopy` | Copies unstaged or commit diff patch to system clipboard |
| **`d`** | `commits` | `git reset --hard` | Permanently drop local commit with confirmation modal |
| **`q`** | Global | Exit | Close Lazygit |

---

## 5. Yazi Terminal File Manager

Launched via `y` (shell wrapper that switches directory on exit) or `yazi`:

| Keybinding | Context | Action |
|---|---|---|
| `h` / `j` / `k` / `l` | Navigation | Parent directory / Down / Up / Enter directory or open file |
| `Ctrl + u` / `Ctrl + d` | Navigation | Half-page up / Half-page down |
| `Ctrl + b` / `Ctrl + f` | Navigation | Full-page up / Full-page down |
| `gg` / `G` | Navigation | Jump to top / Jump to bottom |
| `i` / `T` | Preview | **Toggle full-screen preview mode** |
| `e` | Preview | Toggle preview pane visibility |
| `o` / `O` / `Ctrl + o` | Opener | Open selection with interactive menu |
| `P` | Opener | Open selection with **macOS Quick Look** (`qlmanage`) |
| `M` | Opener | Open selection directly in **MuPDF** |
| `f f` | Search | Fuzzy search file names via `fzf` |
| `f g` | Search | Fuzzy search file contents via `ripgrep` + `fzf` |
| `f s` | Search | Live line search with `rg` + `fzf` and reveal in Yazi |

---

## 6. Terminal Emulators (Ghostty & Alacritty)

### A. Ghostty
* **Multiplexer Integration**: Automatically attaches to or creates the `main` tmux session on start.
* **Extended Keys**: Passes explicit CSI sequences for `Ctrl + Tab` and `Ctrl + Shift + Tab` to tmux.

| Keybinding | Action |
|---|---|
| `Cmd + d` | Split surface right |
| `Cmd + Shift + d` | Split surface down |
| `Cmd + h` / `Cmd + l` | Focus surface left / right |
| `Cmd + k` / `Cmd + j` | Focus surface top / bottom |
| `Cmd + Shift + ]` | Next native tab |
| `Cmd + Shift + [` | Previous native tab |

### B. Alacritty
* **Dynamic Attach**: Re-attaches to `main` if idle, creates new session if `main` is attached.
* **Zero Scrollback**: Directs all scrolling into tmux copy-mode to maintain pane state consistency.

| Keybinding | Action |
|---|---|
| `Ctrl + Shift + U` | Open URL / Regex hint selector |
| `Shift + Return` | Send raw escape return |
| `Ctrl + Tab` | Sent as `C-Tab` (`\x1b[27;5;9~`) |
| `Ctrl + Shift + Tab` | Sent as `C-BTab` (`\x1b[27;6;9~`) |

---

## 7. Karabiner-Elements Window Management

Configured in [`.config/karabiner/karabiner.json`](file:///Users/alex/Github/config/terminal-configs/.config/karabiner/karabiner.json):

| Keybinding | Action |
|---|---|
| `Cmd + Option + h` | Cycle application window backward (`Cmd + Shift + \``) |
| `Cmd + Option + l` | Cycle application window forward (`Cmd + \``) |
| `Right Option` | Remapped to `Left Control` (Ergonomic tmux prefix modifier) |

---

## 8. Custom CLI Helper Binaries & Scripts

Located in [`bin/`](file:///Users/alex/Github/config/terminal-configs/bin) (symlinked to `~/bin`):

| Script | Purpose |
|---|---|
| [`tmux-palette`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-palette) | Interactive Command Palette HUD. Search and trigger any terminal workflow. |
| [`tmux-open-path`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-open-path) | Extracts file paths & compiler stacktraces from screen and opens in Neovim. |
| [`tmux-scratchpad`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-scratchpad) | Floating instant scratchpad and notes editor (`~/notes/scratchpad.md`). |
| [`tmux-ports`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-ports) | Interactive listening ports inspector, process killer, and localhost opener. |
| [`tmux-cheat`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-cheat) | Interactive developer cheatsheet and documentation HUD (`cheat.sh`). |
| [`tmux-dotfiles`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-dotfiles) | Fuzzy dotfiles switcher and live config editor with auto-reload. |
| [`tmux-sessionizer`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-sessionizer) | Interactive project jumper. Scans git repositories and opens or attaches to dedicated tmux session. |
| [`tmux-agent-matrix`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-agent-matrix) | Spawns parallel AI agents in 2-pane, 3-pane, or 4-pane tiled tmux grid layouts. |
| [`session-handoff`](file:///Users/alex/Github/config/terminal-configs/bin/session-handoff) | Exports git branch, uncommitted diffs, and session metadata into structured markdown handoff notes. |
| [`tmux-workspace`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-workspace) | Instant declarative IDE-like workspace layouts (`dev`, `ai`, `triage`). |
| [`tmux-join-panes`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-join-panes) | Interactive fuzzy multi-select pane joiner with live ANSI terminal buffer preview. |
| [`tmux-save-named`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-save-named) | Saves full tmux session snapshot under a custom name in `~/.tmux/resurrect/named/`. |
| [`tmux-restore-named`](file:///Users/alex/Github/config/terminal-configs/bin/tmux-restore-named) | Interactive fuzzy selector to restore any named tmux session snapshot. |
| [`macos-defaults.sh`](file:///Users/alex/Github/config/terminal-configs/bin/macos-defaults.sh) | Applies macOS performance defaults (fast key repeat, Finder tweaks, disable animations). |
| [`git-install-taskwarrior-hook`](file:///Users/alex/Github/config/terminal-configs/bin/git-install-taskwarrior-hook) | Configures git post-commit hooks to update Taskwarrior items automatically. |
| [`mac-bootstrap.sh`](file:///Users/alex/Github/config/terminal-configs/bin/mac-bootstrap.sh) | Complete bootstrap installer for fresh macOS machines. |
| [`linux-bootstrap.sh`](file:///Users/alex/Github/config/terminal-configs/bin/linux-bootstrap.sh) | Complete bootstrap installer for Linux/Ubuntu workstations. |
| [`wsl-bootstrap.sh`](file:///Users/alex/Github/config/terminal-configs/bin/wsl-bootstrap.sh) | Complete bootstrap installer for Windows Subsystem for Linux (WSL2). |
| [`setup.sh`](file:///Users/alex/Github/config/terminal-configs/setup.sh) | Portable, idempotent dotfiles symlink manager with automated collision backups. |

