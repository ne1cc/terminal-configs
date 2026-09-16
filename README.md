# 🖥️ macOS / Linux Terminal Configs & Dotfiles

A premium, curated repository for my complete terminal environment, shell configuration, terminal multiplexer (tmux), GPU-accelerated terminal emulators (Ghostty & Alacritty), file manager (Yazi), Git TUI (Lazygit), and Neovim development environment.

---

## 📖 Master Guides & Documentation

**Start here:** **[docs/README.md](docs/README.md)** — documentation hub with all workflow guides.

### Setup & GitHub
* 🗂️ **[Github Workspace Setup](docs/GITHUB_WORKSPACE_SETUP.md)** — Bootstrap macOS, Linux, WSL
* 🔗 **[Github Aliases Guide](docs/GITHUB_ALIASES_GUIDE.md)** — `ghsync`, `ghn`, `ghr`, archive, pins

### Terminal & shell
* 🖥️ **[tmux Workflow Guide](docs/TMUX_WORKFLOW_GUIDE.md)** — Layouts, palette, AI panes, sessionizer
* 🐚 **[Zsh & Git Workflow Guide](docs/ZSH_GIT_WORKFLOW_GUIDE.md)** — Git power moves, FZF, clipboard, worktrees
* ⚡ **[Modern CLI Guide](docs/MODERN_CLI_GUIDE.md)** — Eza, Bat, Zoxide, Delta, Direnv
* 🪟 **[Terminal Emulators Guide](docs/TERMINAL_EMULATORS_GUIDE.md)** — Ghostty, Alacritty, Karabiner

### Editors & tools
* ✍️ **[Neovim Guide](docs/NEOVIM_GUIDE.md)** — Overview + integrations
* 📖 **[10X Neovim Session](docs/10X_NEOVIM_SESSION.md)** — Find code, trace bugs, edit fast
* 🩺 **[LSP Shortcuts](docs/LSP_SHORTCUTS.md)** — Navigation, diagnostics, rename
* 🐙 **[Lazygit Guide](docs/LAZYGIT_GUIDE.md)** — Git TUI + AI commit/review
* 📁 **[Yazi Guide](docs/YAZI_GUIDE.md)** — Terminal file manager

### AI & productivity
* 🤖 **[AI Workflow Guide](docs/AI_WORKFLOW_GUIDE.md)** — Claude Code, Antigravity, handoffs, agent matrix
* ✅ **[Taskwarrior Guide](docs/TASKWARRIOR_GUIDE.md)** — Task tracking + git hooks

### Quick reference (cheatsheets)
* 🚀 **[Master Cheatsheet](SHORTCUTS.md)** — Every keybinding and alias in one file
* 🗂️ **[tmux Shortcuts](TMUX_SHORTCUTS.md)** — Full tmux binding tables

---

## 📦 What's Included

```
terminal-configs/
├── .config/
│   ├── alacritty/       # Alacritty config (Tokyo Night, vibrancy & tmux integration)
│   ├── ghostty/         # Ghostty GPU terminal configuration & keybinds
│   ├── karabiner/       # Karabiner-Elements keyboard custom modifications
│   ├── lazygit/         # Lazygit config with AI (Antigravity/Claude/Codex) workflows
│   ├── nvim/            # Complete Neovim environment (AstroNvim-based)
│   ├── yazi/            # Yazi terminal file manager config & plugins
│   └── starship.toml    # Cross-shell Starship prompt configuration
├── bin/                 # Custom CLI binaries (tmux-sessionizer, snapshot utilities)
├── claude-code/
│   ├── CLAUDE.md        # Unified global instructions (merged MSTSPAT standards)
│   └── commands/        # Custom slash commands (/plan, /cook, /continue, /release)
├── .gemini/
│   ├── GEMINI.md        # Global Markdown and typography rules
│   └── skills/          # Complete suite of Antigravity AI skills (100+ specialized agents)
├── docs/                # Specialized workflow and shortcut guides
├── .inputrc             # GNU Readline keybindings
├── .p10k.zsh            # Powerlevel10k prompt settings
├── .tmux.conf           # tmux prefix binds, mouse copy, popups, & stashing
├── .zshrc               # Shell aliases, git power moves, & developer utilities
├── Brewfile             # macOS Homebrew packages, casks, and fonts
├── Brewfile.linux       # Linuxbrew package manifest
├── SHORTCUTS.md         # Exhaustive master keyboard & alias reference
├── setup.sh             # Portable, idempotent symlink installer
└── install.sh           # Interactive bootstrap script
```

---

## 🚀 Migration & Quick Start

Follow these steps to fully restore your environment on a fresh machine.

### Step 1: Install Homebrew / Linuxbrew & Restore Packages
On macOS:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file=~/Github/n1ecC/terminal-configs/Brewfile
```

### Step 2: Run the Portable Setup Script
```bash
./setup.sh
```
The script detects macOS, Linux, and WSL; moves existing conflicting files to `~/.terminal-configs-backups/<timestamp>`; establishes symlinks from the repository folder to your home directory; and runs `setup-github-workspace` to create the identical `~/Github` layout on every machine.

**Fresh machine bootstrap** — see **[docs/GITHUB_WORKSPACE_SETUP.md](docs/GITHUB_WORKSPACE_SETUP.md)** for full per-platform walkthrough. Quick start:

```bash
# macOS (Apple Silicon or Intel)
git clone https://github.com/n1ecC/terminal-configs.git ~/Github/n1ecC/terminal-configs
bash ~/Github/n1ecC/terminal-configs/bin/mac-bootstrap.sh

# Linux
bash ~/Github/n1ecC/terminal-configs/bin/linux-bootstrap.sh

# Windows (WSL2)
bash ~/Github/n1ecC/terminal-configs/bin/wsl-bootstrap.sh
```

To restore packages automatically as part of setup:
```bash
./setup.sh --install-packages
```

---

## 🛠️ Configuration Details

### 🐚 Zsh (`.zshrc` & `.p10k.zsh`)
* Integrates **Powerlevel10k** and **Oh My Zsh**.
* **Github workspace aliases:** `ghn`, `ghr`, `ghsync`, `ghar`, `ghpin`, portfolio jumps (`gho`, `ghab`, `ghdhs`, `ghtk`). See [SHORTCUTS.md § H](SHORTCUTS.md).
* Includes developer workflow utilities: `groot`, `gwip`, `copylast`, `port`, `killport`, `serve`, `fkill`, `fo`.
* Antigravity AI audit ledger previewers (`glog`, `gdiff`, `agya`, `agyih`).

### 🗂️ Tmux (`.tmux.conf`)
* Remaps prefix key to `Ctrl + Space`.
* Seamless pane navigation with Neovim (`Ctrl + h/j/k/l`).
* Interactive fuzzy popups for sessionizer, windows, panes, and stashed scratchpads (`Prefix + s/w/e/f`).
* Floating Lazygit modal (`Prefix + Ctrl + g`) and Claude assistants.

### ✍️ Neovim (`.config/nvim`)
* Customized AstroNvim structure with Tokyo Night theme.
* Inline image rendering (`3rd/image.nvim` + `img-clip.nvim`), PDF viewing (`MuPDF`), and FzfLua picker.

### 🤖 Claude Code Workflows (Configuration as Code)
* Integrates a version-controlled global [CLAUDE.md](claude-code/CLAUDE.md) symlinked automatically to `~/.claude/CLAUDE.md`.
* Custom global slash commands in [commands/](claude-code/commands/) symlinked to `~/.claude/commands/` for use in any project:
  * `/plan` — Strategic Planning: Discovers requirements, mapping dependencies, and creating/updating the `TODO.md` roadmap.
  * `/cook` — Focused Implementation: Executes tasks from `TODO.md` in dependency order, enforcing code quality standards.
  * `/continue` — Intelligent Resumption: Inspects git status and `TODO.md` progress to resume work cleanly.
  * `/release` — Production Preparation: Orchestrates lints, formatting, test suites, builds, semantic versioning, and git tags/push.
* Enforces the **MSTSPAT** code quality standard: Minimal, Self-documenting, Type-exact, Secure, Performant, Accessible, and Testable code.
* Mandates structured architectural planning using `<thinking>` tags and strict execution validation checks.

---

## ⚡ Master Shortcuts & Cheatsheet

A complete reference for every configured keyboard shortcut, alias, and shell function. Also available standalone at [SHORTCUTS.md](SHORTCUTS.md).

### 1. tmux Keybindings (Prefix: `Ctrl + Space`)

#### A. Seamless Navigation (Vim + tmux Integration)
| Keybinding | Scope | Description |
|---|---|---|
| `Ctrl + h` | **(No Prefix)** | Focus split / pane to the left (seamless Neovim + tmux) |
| `Ctrl + j` | **(No Prefix)** | Focus split / pane down (seamless Neovim + tmux) |
| `Ctrl + k` | **(No Prefix)** | Focus split / pane up (seamless Neovim + tmux) |
| `Ctrl + l` | **(No Prefix)** | Focus split / pane to the right (seamless Neovim + tmux) |
| `Ctrl + \` | **(No Prefix)** | Jump to last-focused split / pane |
| `Ctrl + Tab` | **(No Prefix)** | Cycle forward to next pane |
| `Ctrl + Shift + Tab` | **(No Prefix)** | Cycle backward to previous pane |

#### B. Window Navigation & Swapping
| Keybinding | Scope | Description |
|---|---|---|
| `Shift + Left Arrow` / `Ctrl + PageUp` / `Ctrl + Shift + h` | **(No Prefix)** | Switch to previous window |
| `Shift + Right Arrow` / `Ctrl + PageDown` / `Ctrl + Shift + l` | **(No Prefix)** | Switch to next window |
| `Ctrl + Shift + Left Arrow` | **(No Prefix)** | Swap / move active window position left in tab bar |
| `Ctrl + Shift + Right Arrow` | **(No Prefix)** | Swap / move active window position right in tab bar |
| `Prefix + \`` / `Prefix + Tab` | Prefix | **Jump to last active window** |
| `Prefix + >` | Prefix | Move active pane into the next window |
| `Prefix + <` | Prefix | Move active pane into the previous window |

#### C. Splitting & Layout
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + \|` | Prefix | Split pane vertically (inherits `$PWD`) |
| `Prefix + -` | Prefix | Split pane horizontally (inherits `$PWD`) |
| `Prefix + c` | Prefix | Create new window (inherits `$PWD`) |
| `Prefix + v` | Prefix | **Smart Split**: horizontal split if widescreen, vertical if tall |
| `Prefix + z` | Prefix | **Toggle Zoom**: maximize or restore current pane |
| `Prefix + b` | Prefix | Toggle top status bar visibility |
| `Prefix + Ctrl + b` | Prefix | Toggle pane border status titles |

#### D. Pane Movement, Resizing & Organization
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

#### E. Breakout Sessions & Multi-Terminal Windows
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Shift + B` | Prefix | Break active pane out into a new foreground window |
| `Prefix + Alt + Shift + B` | Prefix | Break active pane into a **background window** (`M-B`) |
| `Prefix + Alt + p` | Prefix | **Break active pane out into a brand-new tmux session** (prompts for name, auto-switches) |
| `Prefix + Alt + w` / `Prefix + Ctrl + w` | Prefix | **Break current window out into a brand-new tmux session** (prompts for name, auto-switches) |
| `Prefix + Alt + b` | Prefix | Demote all other panes into background windows (`M-b`) |
| `Prefix + Alt + a` | Prefix | Break active pane out into a new session in **Alacritty** (`M-a`) |
| `Prefix + Alt + g` | Prefix | Break active pane → new tmux session → new **Ghostty** window (`tmux-breakout-ghostty`) |
| `Prefix + @` | Prefix | **Break current window out into a new Ghostty process & session** |
| `Prefix + Alt + j` | Prefix | Pull all panes from a chosen window into current window (`M-j`) |
| `Prefix + Alt + m` | Prefix | Push all panes from current window to another window (`M-m`) |

#### F. Interactive Fuzzy Pickers & Popups
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

#### G. Window Stashing (Background Scratchpads)
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Alt + s` | Prefix | **Stash Window**: move current window to background `stash` session (`M-s`) |
| `Prefix + Alt + r` | Prefix | **Retrieve Window**: fuzzy-pick stashed window and restore (`M-r`) |

#### H. Git Worktrees & AI Assistant Integration
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Ctrl + n` | Prefix | Prompt branch name, create git worktree & open Claude window |
| `Prefix + Ctrl + a` | Prefix | Fuzzy-pick existing worktree and open Claude window |
| `Prefix + Ctrl + x` | Prefix | Fuzzy-pick worktree to force-remove (directory + branch) |
| `Prefix + a` | Prefix | Open/reattach persistent centered Claude popup session |
| `Prefix + Ctrl + p` | Prefix | Open/reattach project-specific Claude popup session |
| `Prefix + Shift + A` | Prefix | Open side-by-side Claude pane (35% width split) |
| `Prefix + Ctrl + c` | Prefix | Spawn new full window running Claude in `$PWD` |

#### I. Copy-Mode & Clipboard
| Keybinding | Scope | Description |
|---|---|---|
| `Prefix + Enter` | Prefix | Enter vi copy-mode |
| `Prefix + u` | Prefix | Enter vi copy-mode and scroll half-page up |
| `v` | Copy-Mode | Begin visual character selection |
| `V` | Copy-Mode | Begin visual line selection |
| `y` | Copy-Mode | Yank selection to system clipboard & exit copy-mode |
| `Y` | Copy-Mode | Yank entire line to system clipboard & exit copy-mode |
| `Mouse Drag` | Mouse | Auto-copies selected text to system clipboard with notification toast |

#### J. Session Persistence & Logging
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

### 2. Zsh Aliases, Functions & Shell Keybindings

#### A. Antigravity AI & Ledger Tools
| Command / Alias | Action / Purpose |
|---|---|
| `agy` | Run Google Antigravity CLI |
| `agy-yolo` / `agyy` / `yolo` | Run Antigravity bypassing tool approval prompts (`--dangerously-skip-permissions`) |
| `glog` | Markdown preview of the Antigravity audit ledger (`~/.gemini_history.md`) |
| `gdiff` | Side-by-side syntax-highlighted diff of Antigravity session history |
| `agya` | Export, render, and preview the latest Antigravity session audit report |
| `agyih` | Interactive full Antigravity session audit history viewer |

#### B. Git Power Moves & Daily Aliases
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

#### C. Git Worktree Workflows
| Command / Alias | Action / Purpose |
|---|---|
| `wt-new <branch>` | Create new git worktree with dedicated branch in `.worktrees/<branch>` |
| `wt-tmux-attach` | Fuzzy-pick existing worktree and switch tmux window directly to it |
| `wt-rm` | Fuzzy-pick worktree to cleanly delete worktree and associated branch |

#### D. Claude Code Automation Workflows
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

#### E. Clipboard & Output Ergonomics
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

#### F. Ports, Networking & Local Development
| Command / Alias | Action / Purpose |
|---|---|
| `port <num>` | Inspect listening processes on port (e.g. `port 3000`) |
| `killport <num>` | Terminate all processes listening on port (e.g. `killport 8080`) |
| `serve [port]` | Launch zero-config HTTP static file server in `$PWD` (default: 8000) |
| `myip` | Query public IP address and geo-location details via JSON API |
| `cheat <topic>` | Query terminal cheat sheets from `cheat.sh` (e.g. `cheat tar`) |

#### G. Interactive FZF Superpowers
| Command / Alias | Action / Purpose |
|---|---|
| `fo` | Fuzzy find a file with syntax-highlighted `bat` preview and open in `$EDITOR` |
| `fkill` | Interactive fuzzy process killer with live arguments preview (supports multi-select with `Tab`) |
| `fenv` | Interactive fuzzy search across all environment variables |
| `Ctrl + R` | Interactive fuzzy shell command history search |
| `Ctrl + T` | Interactive fuzzy file picker |
| `Alt + C` | Interactive fuzzy directory navigation |

#### H. Modern CLI Enhancements
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

#### I. Application Launchers & File Handlers
| Command / Alias | Action / Purpose |
|---|---|
| `lg` | Launch Lazygit in current repository |
| `lgd` | Launch Lazygit in dotfiles repository (`$DOTFILES` / `~/Github/n1ecC/terminal-configs`) |
| `mu <file.pdf>` | Open PDF in high-speed MuPDF viewer |
| `om` / `omd` / `onemarkdown` | Open Markdown file in **One Markdown** |
| `mt` / `marktext` | Open Markdown file in **Mark Text** (new window) |
| `prev` / `preview` | Open file in Apple **Preview** |
| `finder` | Open current directory in macOS Finder |
| `of <file>` | Reveal file in macOS Finder (`open -R`) |
| `y` | Launch Yazi file manager (syncs terminal `$PWD` on exit) |

#### J. Shell Ergonomics & Keybindings
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

### 3. Neovim Development Environment (Leader: `Space`)

#### A. Window & Pane Navigation
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

#### B. File Exploration & Fuzzy Find (FzfLua)
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

#### C. Git & Lazygit Integration
| Keybinding | Mode | Action |
|---|---|---|
| `<Leader>gg` / `<Leader><C-g>` / `<Leader>tl` | Normal | **Toggle Floating Lazygit TUI** (`lazygit.nvim`) |
| `<Leader>gS` | Normal | Open Fugitive git status window (`:Git`) |
| `<Leader>gD` | Normal | Open Fugitive git diff window (`:Git diff`) |
| `<Leader>gB` | Normal | Open Fugitive git blame window (`:Git blame`) |
| `<Leader>gP` | Normal | Push commits via Fugitive (`:Git push`) |

#### D. Markdown, Media, Images & PDFs
| Keybinding | Mode | Action |
|---|---|---|
| `<Leader>p` / `<Leader>pi` | Normal | **Paste image from clipboard** directly into Markdown (`img-clip.nvim`) |
| `<Leader>ic` | Normal | **Clear image overlays** (fixes terminal ghosting artifacts) |
| `<Leader>~` / `<Leader>ms` | Normal / Visual | **Toggle strikethrough** (`~~text~~`) |
| `<Leader>op` | Normal | Open PDF under cursor or companion `.pdf` file in **MuPDF** |
| `<Leader>oe` | Normal | Open EPUB under cursor or companion `.epub` file in **OmniReader** |
| `<Leader>om` | Normal | Open Markdown under cursor or buffer in **One Markdown** |
| `<Leader>mt` | Normal | Open Markdown under cursor or buffer in **Mark Text** (new window) |
| `j` / `]i` | Normal (Image buffer) | View next image in folder gallery |
| `k` / `[i` | Normal (Image buffer) | View previous image in folder gallery |

#### E. Neo-tree Sidebar Shortcuts
| Keybinding | Context | Action |
|---|---|---|
| `<CR>` / `o` | Neo-tree | Open file or expand directory |
| `P` | Neo-tree | Toggle floating preview of file under cursor |
| `M` | Neo-tree | Open highlighted PDF directly in **MuPDF** |

#### F. Insert / Command Mode Line Editing
| Keybinding | Mode | Action |
|---|---|---|
| `Alt + K` | Insert / Command | Cut text from cursor to end of line into clipboard (`<C-o>d$`) |
| `Ctrl + K` | Insert / Command | Clear text from cursor to end of line (`<C-o>D`) |

---

### 4. Lazygit Custom Commands & AI Workflows

Available inside Lazygit (`lg` or `Prefix + Ctrl + g`):

| Key | Context | Tool Executed | Description |
|---|---|---|---|
| **`<alt-a>`** | `files` | **Antigravity (`agy`)** | Analyzes staged changes and generates conventional commit title & description |
| **`C`** | `files` | **Claude CLI (`claude`)** | Reviews staged diff for bugs, edge cases, and performance regressions |
| **`X`** | `localBranches` | **OpenAI Codex (`codex`)** | Analyzes branch changes to explain architectural impact |
| **`Q`** | `files` | **Qoder (`qodercli`)** | Audits staged code changes for compliance and safety |
| **`N`** | `global` | **GitHub CLI (`gh`)** | Creates GitHub Pull Request (`gh pr create --fill`) |
| **`O`** | `localBranches` | **GitHub CLI (`gh`)** | Checks out GitHub Pull Request for selected branch |
| **`<ctrl-y>`** | `files` / `commitFiles` | `pbcopy` | Copies full file contents to system clipboard |
| **`<alt-y>`** | `files` / `commitFiles` | `pbcopy` | Copies unstaged or commit diff patch to system clipboard |
| **`d`** | `commits` | `git reset --hard` | Permanently drop local commit with confirmation modal |
| **`q`** | Global | Exit | Close Lazygit |

---

### 5. Yazi Terminal File Manager

Launched via `y` or `yazi`:

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

### 6. Terminal Emulators (Ghostty & Alacritty)

#### A. Ghostty
| Keybinding | Action |
|---|---|
| `Cmd + d` | Split surface right |
| `Cmd + Shift + d` | Split surface down |
| `Cmd + h` / `Cmd + l` | Focus surface left / right |
| `Cmd + k` / `Cmd + j` | Focus surface top / bottom |
| `Cmd + Shift + ]` | Next native tab |
| `Cmd + Shift + [` | Previous native tab |
| `Ctrl + Tab` | Sent as `C-Tab` (`\x1b[27;5;9~`) to cycle tmux panes |
| `Ctrl + Shift + Tab` | Sent as `C-BTab` (`\x1b[27;6;9~`) to cycle tmux panes |

#### B. Alacritty
| Keybinding | Action |
|---|---|
| `Ctrl + Shift + U` | Open URL / Regex hint selector |
| `Shift + Return` | Send raw escape return |
| `Ctrl + Tab` | Sent as `C-Tab` (`\x1b[27;5;9~`) |
| `Ctrl + Shift + Tab` | Sent as `C-BTab` (`\x1b[27;6;9~`) |

---

### 7. Karabiner-Elements Window Management

| Keybinding | Action |
|---|---|
| `Cmd + Option + h` | Cycle application window backward (`Cmd + Shift + \``) |
| `Cmd + Option + l` | Cycle application window forward (`Cmd + \``) |
| `Right Option` | Remapped to `Left Control` (Ergonomic tmux prefix modifier) |
