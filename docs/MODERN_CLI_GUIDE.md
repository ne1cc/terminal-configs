# Modern CLI Guide

Modern replacements for classic Unix tools, plus navigation and environment automation wired into your shell.

**Source:** `.zshrc` aliases and Homebrew/Brewfile packages

---

## Quick start

```bash
ls          # actually eza — icons, git status, colors
cat README  # actually bat — syntax highlighting
z term      # zoxide jump to terminal-configs
zi          # interactive directory picker
cheat jq    # instant cheat sheet
```

---

## Directory navigation

### Zoxide — smart `cd`

Zoxide learns from directories you visit. Jump with partial names:

```bash
z olist              # ? ~/Github/ne1cc/olist-lakehouse
z term               # ? terminal-configs
zi                   # fzf picker over frequent directories
```

**Tip:** You must `cd` into a directory at least once before zoxide remembers it.

### FZF directory jump

| Key | Action |
|-----|--------|
| `Alt + C` | Fuzzy cd into subdirectory |
| `Ctrl + T` | Fuzzy file picker (insert path) |
| `Ctrl + R` | Fuzzy command history |

---

## File listing — Eza (replaces `ls`)

| Alias | Command | Output |
|-------|---------|--------|
| `ls` | `eza --icons --group-directories-first` | Standard list |
| `ll` | `eza -l --icons ...` | Long format |
| `la` | `eza -la --icons ...` | All files |
| `l` | Same as `la` | Shorthand |
| `tree` | `eza --tree --icons` | Tree view |

Features: file icons, git change indicators, directory grouping.

---

## File viewing — Bat (replaces `cat`)

```bash
cat src/main.py      # syntax-highlighted with line numbers
bat --plain file.txt # no decorations
```

Configured with `--style=header,grid,snip --theme=ansi` and inline git change highlights.

Used by FZF preview in `fo` (fuzzy file open).

---

## Disk usage

| Alias | Tool | Action |
|-------|------|--------|
| `df` | `duf` | Filesystem usage (human-readable) |
| `du` | `dust` | Directory size treemap |

---

## Git diffs — Delta

Lazygit and shell git use **Delta** for syntax-highlighted diffs:

```bash
gd                   # piped through delta if configured in gitconfig
gshow                # fzf commit browser with delta preview
```

Side-by-side mode: `gdiff` on Antigravity audit ledger.

---

## Environment automation — Direnv

Auto-load/unload environment variables per directory:

```bash
# In project root
echo 'export DATABASE_URL=postgres://localhost/dev' > .envrc
direnv allow
cd .                 # variables load automatically
cd ..                # variables unload
```

Direnv hooks are loaded in `.zshrc`.

---

## Cheat sheets — cheat.sh

```bash
cheat tar            # tar examples
cheat python/list    # Python list comprehensions
cheat docker/run
```

**tmux:** `Prefix + Alt + c` ? interactive cheat HUD (`tmux-cheat`)

---

## Tmux sessionizer

Fuzzy project switcher — scans `~/Github`:

```bash
Prefix + f           # tmux binding
tmux-sessionizer     # shell script
```

See [TMUX_WORKFLOW_GUIDE.md](TMUX_WORKFLOW_GUIDE.md).

---

## Smart tmux splits

`Prefix + v` — layout-aware split:

- **Wide terminal** ? horizontal split (side by side)
- **Tall terminal** ? vertical split (stacked)

Inherits current working directory.

---

## Other modern tools (Brewfile)

Installed via `brew bundle` / bootstrap scripts:

| Tool | Purpose |
|------|---------|
| `ripgrep` (`rg`) | Fast code search — Neovim, Yazi, fzf |
| `fd` | Fast file finder |
| `fzf` | Fuzzy finder backbone |
| `jq` / `yq` | JSON/YAML processing |
| `httpie` | HTTP client |
| `btop` / `htop` | Process monitor (tmux palette) |
| `glow` | Markdown preview (`glog` alias) |
| `delta` | Git diff pager |
| `starship` | Cross-shell prompt |
| `uv` | Fast Python package manager |
| `fnm` | Node version manager |
| `gh` | GitHub CLI |
| `lazygit` | Git TUI |
| `yazi` | File manager |
| `duckdb` | Embedded analytics SQL |

---

## Package manifests

| File | Platform |
|------|----------|
| `Brewfile` | macOS (Homebrew) |
| `Brewfile.linux` | Linux (Linuxbrew) |

Install:

```bash
brew bundle --file=~/Github/ne1cc/terminal-configs/Brewfile
```

Or during bootstrap: `mac-bootstrap.sh` / `linux-bootstrap.sh`

---

## Daily workflows

### Explore unfamiliar repo

```bash
z myproject
tree -L 2
fo                   # fuzzy find + bat preview ? nvim
```

### Check disk before large dataset

```bash
df
du -d 1 workspace/datasets
```

### Quick API test

```bash
http GET localhost:8000/health
prettyjson <<< '{"a":1}'
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `ls` looks plain | Install `eza`; check alias in `.zshrc` |
| `bat` not found | `brew install bat` |
| Zoxide no match | Visit directory once with `cd` |
| Direnv blocked | Run `direnv allow` in project root |
| Icons missing | Install Nerd Font (JetBrainsMono Nerd Font in Brewfile) |

---

## Related docs

- [ZSH_GIT_WORKFLOW_GUIDE.md](ZSH_GIT_WORKFLOW_GUIDE.md) — FZF, git, ports
- [TMUX_WORKFLOW_GUIDE.md](TMUX_WORKFLOW_GUIDE.md) — sessionizer, smart splits
- [GITHUB_WORKSPACE_SETUP.md](GITHUB_WORKSPACE_SETUP.md) — bootstrap packages

---

## Cheat sheet

```
Navigate:   z <name>  zi  Alt+C
List:       ls  ll  la  tree
View:       cat (bat)  glow file.md
Disk:       df (duf)  du (dust)
Search:     fo  Ctrl+R  Ctrl+T
Env:        direnv allow
Docs:       cheat <topic>
```
