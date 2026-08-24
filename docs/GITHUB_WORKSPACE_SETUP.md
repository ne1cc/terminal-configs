# Github Workspace Setup Guide

Step-by-step instructions to get the same `~/Github` directory tree, shell aliases, and sync scripts on every machine: **macOS (Apple Silicon or Intel)**, **Linux**, and **Windows (WSL2)**.

All layout logic lives in `terminal-configs`. Running any bootstrap or `install.sh` calls `setup-github-workspace`, which creates identical folders and symlinks `_tools/` scripts back to this repo.

---

## What you get

After setup, every machine has:

```
~/Github/
├── n1ecC/              # Your github.com/n1ecC repos — push from here
├── config/             # Local dotfiles, scripts, machine overrides
├── explore/            # Third-party clones (read-only)
├── workspace/          # Local-only work (msba, sandboxes, datasets)
├── archive/            # Cold storage + MANIFEST.md
├── tracking/           # Job search / application tracking
└── _tools/             # Symlinks → terminal-configs/bin/
```

Shell aliases (after `source ~/.zshrc`): `ghn`, `ghr`, `ghsync`, `ghar`, `ghpin`, `ghroot`, etc. See [SHORTCUTS.md § H](../SHORTCUTS.md).

---

## Prerequisites (all platforms)

Install these **before** bootstrap if they are not already present:

| Tool | Purpose | Install |
|------|---------|---------|
| **git** | Clone repos | macOS: Xcode CLT or Homebrew. Linux/WSL: `sudo apt install git` |
| **zsh** | Shell | macOS: default. Linux/WSL: `sudo apt install zsh` |
| **gh** | GitHub CLI (for `sync-n1ecC`) | [cli.github.com](https://cli.github.com/) |
| **GNU Stow** | Dotfile symlinks | macOS: `brew install stow`. Linux/WSL: `sudo apt install stow` |

Authenticate GitHub CLI once per machine:

```bash
gh auth login
gh auth status
```

---

## Fresh machine — common first step

Every platform starts by cloning `terminal-configs` into the canonical path. Create the parent folder first:

```bash
mkdir -p ~/Github/n1ecC
git clone https://github.com/n1ecC/terminal-configs.git ~/Github/n1ecC/terminal-configs
cd ~/Github/n1ecC/terminal-configs
```

Then run the **one** bootstrap script for your OS (sections below).

---

## macOS (Apple Silicon M1 / M1 Max, or Intel)

Works on both `/opt/homebrew` (Apple Silicon) and `/usr/local` (Intel). `.zprofile` detects Homebrew automatically.

### Option A — Full bootstrap (recommended on a new Mac)

Installs Homebrew, optional Brewfile packages, Oh My Zsh, Powerlevel10k, dotfiles, Github workspace, and links all bin scripts.

```bash
mkdir -p ~/Github/n1ecC
git clone https://github.com/n1ecC/terminal-configs.git ~/Github/n1ecC/terminal-configs
bash ~/Github/n1ecC/terminal-configs/bin/mac-bootstrap.sh
```

When prompted, answer **`y`** to install Brewfile packages (Ghostty, fnm, stow, gh, etc.) unless you want to install them manually later:

```bash
brew bundle --file=~/Github/n1ecC/terminal-configs/Brewfile
```

### Option B — Dotfiles + workspace only (Homebrew already set up)

```bash
cd ~/Github/n1ecC/terminal-configs
./install.sh
```

Or the portable installer with collision backups:

```bash
./setup.sh
./setup.sh --install-packages   # also runs brew bundle
```

### macOS post-setup

```bash
source ~/.zshrc
fnm install --lts                 # if Node not installed yet
ghsync-list                       # list remote repos vs local clones
ghsync                            # clone missing n1ecC repos
```

Restart Ghostty (or your terminal) so `.zprofile` and `.zshrc` load cleanly.

---

## Linux (Ubuntu / Debian)

Uses Linuxbrew, apt packages, Nerd Fonts, and sets zsh as the default shell when possible.

### Full bootstrap (recommended on a new machine)

```bash
mkdir -p ~/Github/n1ecC
git clone https://github.com/n1ecC/terminal-configs.git ~/Github/n1ecC/terminal-configs
bash ~/Github/n1ecC/terminal-configs/bin/linux-bootstrap.sh
```

The script will:

1. Install apt packages (git, zsh, build tools, clipboard utils)
2. Install Linuxbrew if missing
3. Optionally install packages from `Brewfile.linux` (prompted)
4. Install Oh My Zsh + Powerlevel10k
5. Run `install.sh` (Stow dotfiles, link bin scripts, `setup-github-workspace`)
6. Set git credential helper and zsh as default shell

If Stow reports conflicting absolute symlinks, answer **`y`** to remove them and re-link.

### Linux post-setup

```bash
source ~/.zshrc
ghsync-list
ghsync
tmux source ~/.tmux.conf
```

Log out and back in (or run `chsh -s $(which zsh)`) if zsh is not yet your login shell.

---

## Windows (WSL2)

Native Windows does **not** run these scripts. Use **WSL2** (Ubuntu recommended). Your `~/Github` tree lives inside the Linux filesystem (`/home/<you>/Github`), not under `C:\`.

### 1. Install WSL2 (once, from PowerShell as Administrator)

```powershell
wsl --install
```

Restart if prompted, then open **Ubuntu** from the Start menu.

### 2. Bootstrap inside WSL

```bash
mkdir -p ~/Github/n1ecC
git clone https://github.com/n1ecC/terminal-configs.git ~/Github/n1ecC/terminal-configs
bash ~/Github/n1ecC/terminal-configs/bin/wsl-bootstrap.sh
```

`wsl-bootstrap.sh` runs the full Linux bootstrap, then adds:

- WSL interop settings in `/etc/wsl.conf`
- Windows clipboard check (`clip.exe`)
- JetBrainsMono Nerd Font copy to Windows fonts (for Ghostty/Alacritty on Windows)
- `wslu` / `wslview` for opening URLs in the Windows browser

### WSL post-setup

From **PowerShell**:

```powershell
wsl --shutdown
```

Reopen WSL, then:

```bash
source ~/.zshrc
gh auth login
ghsync-list
ghsync
```

Install **Ghostty** or **Alacritty** on the Windows side and point the font to JetBrainsMono Nerd Font if it was not copied automatically.

---

## Existing machine — pull updates

When `terminal-configs` changes on another machine:

```bash
cd ~/Github/n1ecC/terminal-configs
git pull
./install.sh
source ~/.zshrc
```

`install.sh` re-runs Stow, re-links `~/bin` scripts, and idempotently refreshes the `~/Github` layout via `setup-github-workspace` (existing files are not overwritten).

To recreate only the directory tree and `_tools` symlinks:

```bash
setup-github-workspace
```

---

## Scripts reference

| Script | When to run | What it does |
|--------|-------------|--------------|
| `bin/mac-bootstrap.sh` | New Mac | Homebrew, packages, Oh My Zsh, Stow, Github workspace |
| `bin/linux-bootstrap.sh` | New Linux box | apt, Linuxbrew, fonts, Stow, Github workspace |
| `bin/wsl-bootstrap.sh` | New WSL install | Linux bootstrap + WSL interop/fonts |
| `install.sh` | Re-link after `git pull` | Stow dotfiles, link bin, TPM, Github workspace |
| `setup.sh` | Portable install / conflicts | Backs up conflicts, links dotfiles + workspace |
| `bin/setup-github-workspace` | Layout only | Creates `~/Github` tree + `_tools` symlinks |
| `bin/sync-n1ecC` / `ghsync` | After setup | Clone/pull all n1ecC repos |
| `bin/gharchive` / `ghar` | As needed | Move projects to `~/Github/archive/` |
| `bin/pin-portfolio` / `ghpin` | Once | Open GitHub profile pin instructions |
| `bin/setup-github-profile` | Optional | Update GitHub bio via `gh api` |

All scripts in `bin/` are symlinked to `~/bin` by `install.sh` / `link-stow-extras.sh`.

---

## Verify setup

Run these on any platform:

```bash
# Dotfiles linked
ls -l ~/.zshrc ~/.zprofile
# Should point to ~/Github/n1ecC/terminal-configs/

# Github layout
ls ~/Github/n1ecC ~/Github/explore ~/Github/workspace ~/Github/_tools

# _tools symlinks
ls -l ~/Github/_tools/sync-n1ecC
# Should point to terminal-configs/bin/sync-n1ecC

# Aliases
source ~/.zshrc
ghroot    # cd ~/Github
ghn       # cd ~/Github/n1ecC
ghsync-list

# Clone portfolio repos
ghsync
```

---

## Daily workflow

```bash
ghsync-pull              # start of session — pull existing clones
ghr olist-lakehouse        # cd into a repo
# ... edit, commit ...
git push origin main
```

Archive a local project:

```bash
ghar my-old-sandbox              # from explore/ or workspace/
ghar --from-n1ecc old-repo-name  # from n1ecC/ (excludes from future sync)
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `ghsync` fails with auth error | `gh auth login` then retry |
| Stow conflicts on Linux | Re-run bootstrap and answer **y** to remove old symlinks, or use `./setup.sh` |
| Aliases not found | `source ~/.zshrc` or open a new terminal |
| `DOTFILES` path wrong | Check `~/.zprofile` — should be `$HOME/Github/n1ecC/terminal-configs` |
| WSL can't find `clip.exe` | Run `wsl --shutdown`, ensure `[interop]` in `/etc/wsl.conf` |
| Wrong Homebrew on Mac | Apple Silicon: `/opt/homebrew`. Intel: `/usr/local`. Both handled in `.zprofile` |

---

## Related docs

- [SHORTCUTS.md § H](../SHORTCUTS.md) — Github workspace aliases
- [README.md](../README.md) — Full terminal-configs overview
- `~/Github/README.md` — Local workspace conventions (created by `setup-github-workspace`)
