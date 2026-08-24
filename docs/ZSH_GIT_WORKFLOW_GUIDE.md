# Zsh & Git Workflow Guide

Shell aliases, git power moves, FZF tools, clipboard helpers, ports, worktrees, and project bootstrapping.

**Source:** `.zshrc` (loaded via `source ~/.zshrc`)  
**Cheatsheet:** [SHORTCUTS.md § 2](../SHORTCUTS.md)

---

## Quick start

```bash
groot                 # jump to repo root from any subfolder
gs                    # concise git status
gb                    # fuzzy branch switcher
gwip                  # quick WIP commit
copylast              # copy previous command output
port 8000             # what's listening on this port?
fo                    # fuzzy find file ? open in $EDITOR
```

---

## Git daily aliases

| Alias | Command | Use when |
|-------|---------|----------|
| `gs` | `git status -sb` | Quick status with branch tracking |
| `gd` | `git diff` | Unstaged changes |
| `gds` | `git diff --staged` | Staged changes |
| `gaa` | `git add -A` | Stage everything |
| `gco` | `git checkout` | Switch branch |
| `gcb` | `git checkout -b` | Create + switch branch |
| `gl` | Graph log (20 commits) | Recent history |
| `gc` | `git clone` | Clone repo |
| `gis` | Check if inside git repo | Guard scripts |

---

## Git power moves

| Alias | What it does | Caution |
|-------|--------------|---------|
| `groot` | `cd` to repo root | Safe |
| `gundo` | Soft reset last commit (keeps staged) | Rewrites history locally |
| `gwip` | Commit `wip: save point [skip ci]` | Bypasses hooks |
| `gunwip` | Undo last WIP commit if message matches | Safe if last commit was WIP |
| `gpristine` | Hard reset + clean all untracked/ignored | **Destructive** |
| `gignored` | List ignored files | Safe |
| `gauthors` | Commit count per author | Safe |

### WIP workflow

```bash
# Save work before switching branches
gwip
gco other-branch
# ... work ...
gco feature-branch
gunwip              # removes WIP commit, keeps changes unstaged
```

---

## Interactive git (FZF)

### Branch switcher — `gb`

Opens fzf with all local branches. Preview pane shows commit graph for highlighted branch. `Enter` checks out.

### Commit browser — `gshow`

Fzf over all commits. Preview shows full diff. `Enter` opens in pager.

### Clean merged branches — `gb-clean`

Safely deletes local branches already merged into the default remote branch.

---

## Git worktrees

Parallel branches in separate directories — ideal for reviews, hotfixes, or AI sessions.

| Command | Action |
|---------|--------|
| `wt-new <branch>` | Create worktree at `.worktrees/<branch>` |
| `wt-tmux-attach` | Fzf-pick worktree ? switch tmux window to it |
| `wt-rm` | Fzf-pick worktree ? delete dir + branch |

**tmux integration:** `Prefix + Ctrl + n/a/x` — see [TMUX_WORKFLOW_GUIDE.md](TMUX_WORKFLOW_GUIDE.md).

```bash
wt-new fix-ci-timeout
cd .worktrees/fix-ci-timeout
# ... fix ...
wt-rm    # pick and remove when done
```

---

## Clipboard & output capture

| Command | Action |
|---------|--------|
| `copylast` | Copy output of previous command |
| `copylast 50` | Copy last 50 lines of output |
| `copylast -a` | Copy entire pane scrollback |
| `cbranch` | Copy current branch name |
| `csha` | Copy latest commit SHA |
| `cpath [file]` | Copy absolute path of cwd or file |
| `cpfile <file>` | Copy entire file contents |
| `snap` | Screenshot ? clipboard + `~/Pictures/Screenshots` |

`copylast` uses tmux pane capture when inside tmux — zero side effects on your shell history.

---

## Ports & local development

| Command | Action |
|---------|--------|
| `port <num>` | Show processes listening on port |
| `killport <num>` | Kill all listeners on port |
| `serve [port]` | Static HTTP server in `$PWD` (default 8000) |
| `myip` | Public IP + geo via ipinfo.io |
| `cheat <topic>` | Query cheat.sh (e.g. `cheat tar`) |

**tmux:** `Prefix + Alt + k` opens interactive port inspector (`tmux-ports`).

---

## FZF superpowers

| Command | Action |
|---------|--------|
| `fo` | Fuzzy find file ? bat preview ? open in `$EDITOR` |
| `fkill` | Fuzzy process killer (multi-select with Tab) |
| `fdocker` | Fuzzy Docker container ? attach shell |
| `fssh` | Fuzzy SSH host from `~/.ssh/config` |
| `fenv` | Fuzzy search environment variables |
| `Ctrl + R` | Fuzzy command history |
| `Ctrl + T` | Fuzzy file picker |
| `Alt + C` | Fuzzy directory jump |

---

## Navigation & directories

| Command | Action |
|---------|--------|
| `z <partial>` | Zoxide smart jump (e.g. `z olist`) |
| `zi` | Interactive zoxide picker |
| `ghn` / `ghr` / `ghroot` | GitHub workspace jumps — see [GITHUB_ALIASES_GUIDE.md](GITHUB_ALIASES_GUIDE.md) |
| `..` / `...` / `....` | Up 1/2/3 directory levels |
| `mcd <dir>` | mkdir -p && cd |

---

## Application launchers

| Command | Action |
|---------|--------|
| `lg` | Lazygit in current repo |
| `lgd` | Lazygit in dotfiles (`$DOTFILES`) |
| `y` | Yazi file manager (cd syncs on exit) |
| `mu <pdf>` | MuPDF viewer |
| `om` / `mt` | Open markdown in One Markdown / Mark Text |
| `prev` | macOS Preview |
| `finder` | Open cwd in Finder |
| `of <file>` | Reveal file in Finder |

---

## Docker shortcuts

| Alias | Action |
|-------|--------|
| `d` | `docker` |
| `dc` | `docker compose` |
| `dps` | Formatted container list |
| `dlogs` | Follow logs (last 100 lines) |

**tmux:** `Prefix + Ctrl + d` — fuzzy Docker exec jumper.

---

## Project bootstrapping

| Command | Action |
|---------|--------|
| `venv` | `uv venv && source .venv/bin/activate` |
| `mkpy <name>` | Bootstrap Python project template |
| `mkts <name>` | Bootstrap TypeScript project template |
| `duck` | Launch DuckDB CLI |
| `headcsv` / `tailcsv` | Preview CSV (20 lines) |
| `prettyjson` | Format JSON from stdin |
| `extract <archive>` | Universal archive extractor |

---

## Shell ergonomics

| Command | Action |
|---------|--------|
| `path` | Print `$PATH` one entry per line |
| `extract` | `.tar.gz`, `.zip`, `.rar`, `.7z`, `.bz2`, etc. |
| `Ctrl + A` | Beginning of line |
| `Ctrl + E` | End of line |
| `Alt + K` | Kill line from cursor to end |

---

## tmux shell aliases

| Alias | Action |
|-------|--------|
| `ta` | Attach to `main` session (or create) |
| `tl` | List tmux sessions |
| `tk <name>` | Kill session |

---

## Daily workflows

### Start work on existing repo

```bash
ghr ab-testing-dagster
gs
gb                    # switch branch if needed
```

### Quick experiment on side branch

```bash
wt-new experiment-duckdb
# ... work in .worktrees/experiment-duckdb ...
wt-rm
```

### Debug port conflict

```bash
port 5173
killport 5173
serve 8000            # restart static server
```

### Capture test output for AI

```bash
pytest -x
copylast              # paste into Claude/Antigravity
```

### Share file path in Slack

```bash
cpath src/pipeline/main.py
# paste from clipboard
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `gb` / `fo` empty | Must be inside git repo / project dir |
| `copylast` empty | Run a command first; must be in tmux for best results |
| `killport` permission denied | Use `sudo killport` or kill PID manually |
| `z` doesn't find dir | Visit the directory once — zoxide learns from `cd` |
| FZF keys wrong | Check `$FZF_DEFAULT_OPTS` in `.zshrc` |

---

## Cheat sheet

```
Status:     gs  gd  gds  gl  gaa
Power:      groot  gwip  gunwip  gundo  gpristine
Interactive: gb  gshow  gb-clean
Worktrees:  wt-new  wt-tmux-attach  wt-rm
Clipboard:  copylast  cbranch  csha  cpath  cpfile
Ports:      port  killport  serve
FZF:        fo  fkill  fdocker  fssh  Ctrl+R
Launch:     lg  y  mu  om
```
