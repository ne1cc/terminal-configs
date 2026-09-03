# GitHub Workspace Aliases & Tools — Getting Started

A practical guide to the `gh*` shell aliases, sync scripts, and daily workflow for your `~/Github` workspace.

**Documentation hub:** [README.md](README.md) · **Machine setup:** [GITHUB_WORKSPACE_SETUP.md](GITHUB_WORKSPACE_SETUP.md)

**Account:** [github.com/n1ecC](https://github.com/n1ecC)  
**Canonical repo:** `terminal-configs` (where these scripts and aliases live)

For first-time machine setup (macOS, Linux, WSL), see **[GITHUB_WORKSPACE_SETUP.md](GITHUB_WORKSPACE_SETUP.md)** first. This guide assumes that setup is done and aliases are loaded.

---

## Quick start (5 minutes)

```bash
# 1. Authenticate GitHub CLI (once per machine)
gh auth login
gh auth status

# 2. Load aliases (or open a new terminal)
source ~/.zshrc

# 3. See what's cloned vs missing on GitHub
ghsync-list

# 4. Clone anything missing + pull everything you have
ghsync

# 5. Jump into your repos
ghn              # cd ~/Github/n1ecC
ghr              # list all local repo folders
ghr olist-lakehouse
```

---

## Prerequisites

| Tool | Why you need it |
|------|-----------------|
| **git** | Clone, commit, push |
| **gh** (GitHub CLI) | List repos, clone via `gh repo clone`, profile updates |
| **zsh** + **terminal-configs** dotfiles | Aliases live in `.zshrc` |

Install `gh`: [cli.github.com](https://cli.github.com/)

Authenticate once:

```bash
gh auth login
```

For profile bio updates (`setup-github-profile`), refresh scopes:

```bash
gh auth refresh -h github.com -s user
```

---

## Environment variables

Set in `~/.zprofile` (loaded at login):

| Variable | Default | Purpose |
|----------|---------|---------|
| `GITHUB_ROOT` | `$HOME/Github` | Root of your dev workspace |
| `N1ECC_DIR` | `$GITHUB_ROOT/n1ecC` | All your GitHub repos (push from here) |

Override for one-off runs:

```bash
N1ECC_DIR=/tmp/test ghsync-list
```

---

## Folder layout (mental model)

```
~/Github/
??? n1ecC/          # YOUR repos — single source of truth for pushing to GitHub
??? config/         # Dotfiles, scripts, machine-specific overrides
??? explore/        # Third-party clones (read-only; fork to n1ecC/ if you keep changes)
??? workspace/      # Local-only work (sandboxes, coursework, datasets)
??? archive/        # Cold storage + MANIFEST.md
??? tracking/       # Job search / application tracking
??? _tools/         # Symlinks ? terminal-configs/bin/ scripts
```

**Conventions:**

1. Only **`n1ecC/`** gets pushed to your GitHub account.
2. **`explore/`** is for learning — clone, read, delete; don't customize in place.
3. **`workspace/`** stays local until you promote a project to `n1ecC/`.
4. Large datasets go in `workspace/datasets/` or repo-local `data/` (gitignored).

---

## Shell aliases reference

All aliases are defined in `terminal-configs/.zshrc`. Equivalent bin scripts are symlinked in `~/bin` and `~/Github/_tools/`.

### Navigation

| Alias | Action |
|-------|--------|
| `ghroot` | `cd ~/Github` |
| `ghn` | `cd ~/Github/n1ecC` — all your GitHub repos |
| `ghex` | `cd ~/Github/explore` |
| `ghws` | `cd ~/Github/workspace` |
| `ghcfg` | `cd ~/Github/config` |

### Repo navigation

| Command | Action |
|---------|--------|
| `ghr` | List all folders in `~/Github/n1ecC/` |
| `ghr <repo>` | `cd ~/Github/n1ecC/<repo>` |

### Portfolio quick-jumps

| Alias | Repo |
|-------|------|
| `gho` | `olist-lakehouse` |
| `ghab` | `ab-testing-dagster` |
| `ghdhs` | `dhs-stunting-pipeline` |
| `ghtk` | `ticker-change` |

### Sync & maintenance

| Alias | Runs | Purpose |
|-------|------|---------|
| `ghsync` | `sync-n1ecC` | Clone missing repos + pull existing |
| `ghsync-list` | `sync-n1ecC --list` | Show clone status and dirty repos |
| `ghsync-pull` | `sync-n1ecC --pull` | Pull existing clones only (no new clones) |
| `ghar` | `gharchive` | Move projects to `~/Github/archive/` |
| `ghpin` | `pin-portfolio` | Open GitHub profile + pin instructions |

### Direct script names (same as aliases)

| Script | Same as |
|--------|---------|
| `sync-n1ecC` | `ghsync` |
| `gharchive` | `ghar` |
| `pin-portfolio` | `ghpin` |
| `setup-github-workspace` | Creates `~/Github` tree + `_tools` symlinks |
| `setup-github-profile` | Update GitHub bio via `gh api` |

---

## Sync: `ghsync`, `ghsync-pull`, `ghsync-list`

The sync engine is **`sync-n1ecC`** (`~/Github/n1ecC/terminal-configs/bin/sync-n1ecC`), symlinked from `~/Github/_tools/sync-n1ecC`.

### What it syncs

- **Source:** All repos on your GitHub account via `gh api user/repos`
- **Destination:** `~/Github/n1ecC/<repo-name>/`
- **Excluded from listing:** Forks, and `SystemDashboard` (org repo that shouldn't mirror locally)

### Three modes

| Command | Mode | Use when |
|---------|------|----------|
| `ghsync` | `--sync` (default) | New machine, new repo on GitHub, or full refresh |
| `ghsync-pull` | `--pull` | Start of session — update repos you already have |
| `ghsync-list` | `--list` | Inspect status without changing anything |

### Per-repo behavior

**Already cloned:**

1. Sets `origin` to `https://github.com/n1ecC/<repo>.git`
2. `git fetch origin --prune` — download latest commits/branches, remove stale remote refs
3. `git pull --ff-only origin <current-branch>` — fast-forward only (no merge commit)

**Not cloned yet:**

1. `gh repo clone n1ecC/<repo> ~/Github/n1ecC/<repo>`
2. Skipped if repo is in `~/Github/_tools/archive-exclude.txt`

### What sync does **not** do

| Does | Does not |
|------|----------|
| Clone missing repos (`ghsync` only) | Push your local commits |
| Pull / fast-forward existing clones | Resolve merge conflicts |
| Skip archived repos (exclude list) | Sync third-party repos in `explore/` |
| Warn on pull failure | Overwrite uncommitted local work |

Sync is a **one-way mirror: GitHub ? local**. Pushing is still manual:

```bash
ghr my-repo
git add -A && git commit -m "..."
git push origin main
```

### `ghsync-list` output

```
  [ok] olist-lakehouse (main)       ? cloned, clean
  [ok] ticker-change (main) *       ? cloned, dirty (uncommitted changes)
  [--] some-new-repo  (not cloned)  ? on GitHub but not local yet
```

The `*` means uncommitted local changes. Pull may fail on that repo until you commit, stash, or discard.

**Filter to dirty repos only:**

```bash
ghsync-list | rg '\*'
```

### When pull fails

```
WARN: ticker-change pull failed (local changes or diverged branch?)
```

Common causes:

- **Dirty repo** — uncommitted changes block pull
- **Diverged branch** — you have local commits that aren't on remote (or vice versa); `--ff-only` refuses to merge

Fix dirty repos:

```bash
ghr ticker-change
git status
git stash          # or commit, or discard
ghsync-pull
```

Fix diverged branches manually inside the repo (`git pull --rebase`, merge, or reset — your choice).

---

## Archive: `ghar` / `gharchive`

Move local project folders into `~/Github/archive/` with a dated path and a manifest entry. **Does not delete anything on GitHub** unless you do that separately.

### Usage

```bash
ghar my-old-sandbox              # search explore/, workspace/, n1ecC/
ghar /full/path/to/dir           # explicit path
ghar --list                      # show archived projects
ghar --from-n1ecc old-repo-name  # archive from n1ecC/ (excludes from future sync)
```

### Behavior

- Moves folder to `archive/YYYY-MM-DD_<name>/` (adds suffix if collision)
- Appends row to `archive/MANIFEST.md`
- Preserves `.git` history in the archived copy
- Warns if uncommitted changes exist, but still archives

### Archiving from `n1ecC/`

Repos in `n1ecC/` are protected by default — you must use `--from-n1ecc`:

```bash
ghar --from-n1ecc wingstop-experiment
```

This also adds the repo name to `~/Github/_tools/archive-exclude.txt`, so **`ghsync` will not re-clone it**.

---

## Portfolio pins: `ghpin` / `pin-portfolio`

Opens your GitHub profile and prints the recommended pin order:

1. `olist-lakehouse`
2. `ab-testing-dagster`
3. `dhs-stunting-pipeline`
4. `ticker-change`

GitHub allows **6 pinned repos** — use the remaining slots for projects like `clinical-trial-intelligence` or `ticker-change-intelligence`.

---

## Profile bio: `setup-github-profile`

Updates your GitHub bio via the API (requires `gh auth` with `user` scope):

```bash
setup-github-profile
# or
~/Github/_tools/setup-github-profile
```

Edit the `BIO` string inside the script to change the text (max 160 characters).

---

## Daily workflows

### Start of session

```bash
ghsync-pull              # fast — pull existing clones only
ghsync-list | rg '\*'    # optional — see what still has local edits
```

### New repo on GitHub

```bash
# Created repo on github.com/n1ecC/my-new-project
ghsync                   # clones it into ~/Github/n1ecC/
ghr my-new-project
```

### Active development

```bash
ghab                     # cd ab-testing-dagster
# ... edit ...
git add -A && git commit -m "fix CI"
git push origin main
```

### New project from template

```bash
cp -r ~/Github/workspace/sandboxes/de-project-template ~/Github/n1ecC/my-new-project
cd ~/Github/n1ecC/my-new-project
make install && make check
# create repo on GitHub, then:
git remote add origin https://github.com/n1ecC/my-new-project.git
git push -u origin main
```

### Before interviews / portfolio review

```bash
ghsync-pull
ghsync-list              # confirm clean, up to date
ghpin                    # verify pins on profile
```

### Retire a local clone (keep GitHub repo)

```bash
ghar --from-n1ecc old-experiment
ghsync-list              # should show [--] not cloned
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `command not found: ghsync` | `source ~/.zshrc` or open a new terminal |
| `ghsync` auth error | `gh auth login` then retry |
| Pull fails on one repo | Check `git status` in that repo; commit, stash, or resolve divergence |
| Repo keeps re-cloning after archive | Confirm it's in `_tools/archive-exclude.txt` |
| Wrong workspace path | Check `echo $GITHUB_ROOT` — should be `~/Github` |
| Aliases point at old paths | `cd ~/Github/n1ecC/terminal-configs && ./install.sh` |
| `ghar` can't find project | Use full path, or check explore/workspace/n1ecC spelling |
| Bio update fails | `gh auth refresh -h github.com -s user` |

---

## Script locations

| Path | Role |
|------|------|
| `terminal-configs/bin/sync-n1ecC` | Sync engine (canonical) |
| `terminal-configs/bin/gharchive` | Archive tool |
| `terminal-configs/bin/pin-portfolio` | Pin instructions |
| `terminal-configs/bin/setup-github-profile` | Bio updater |
| `terminal-configs/bin/setup-github-workspace` | Layout + `_tools` symlinks |
| `~/Github/_tools/*` | Symlinks to `terminal-configs/bin/` |
| `~/bin/*` | Symlinks (via `install.sh`) |

After updating `terminal-configs` on another machine:

```bash
cd ~/Github/n1ecC/terminal-configs
git pull
./install.sh
source ~/.zshrc
```

---

## Related docs

| Doc | Contents |
|-----|----------|
| [GITHUB_WORKSPACE_SETUP.md](GITHUB_WORKSPACE_SETUP.md) | Fresh machine bootstrap (macOS, Linux, WSL) |
| [SHORTCUTS.md § H](../SHORTCUTS.md) | Quick alias table (all terminal shortcuts) |
| `~/Github/README.md` | Local workspace conventions and portfolio list |

---

## Cheat sheet

```bash
# Navigate
ghroot    ghn    ghex    ghws    ghcfg
ghr [repo]    gho    ghab    ghdhs    ghtk

# Sync
ghsync-list          # status
ghsync               # clone missing + pull all
ghsync-pull          # pull existing only

# Maintain
ghar [--from-n1ecc] <name>    # archive locally
ghpin                         # profile pins
setup-github-profile          # update bio

# Push (manual, inside a repo)
git push origin main
```
