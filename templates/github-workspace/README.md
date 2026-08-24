# ~/Github — Development Workspace

Canonical home for all Git work on this machine.

**Path:** `~/Github` (capital `G` — same on macOS, Linux, and WSL)

---

## Folder layout

```
~/Github/
??? n1ecC/          # YOUR repos (github.com/n1ecC) — push from here
??? config/         # Dotfiles & machine config
?   ??? dotfiles/
?   ??? scripts/
?   ??? analytics/
?   ??? docs/
?   ??? external/
?   ??? local/      # machine-specific — never commit
??? explore/        # Third-party clones for learning / reference
??? workspace/      # Local-only work (school, sandboxes, datasets)
?   ??? msba/
?   ??? sandboxes/
?   ??? datasets/   # large files (gitignored)
??? archive/        # Cold storage + MANIFEST.md
??? tracking/       # Job search / application tracking
??? _tools/         # Symlinks to terminal-configs/bin scripts
```

Created automatically by `setup-github-workspace` (runs on `install.sh`, `setup.sh`, and bootstrap).

---

## Shell aliases

| Alias | Action |
|-------|--------|
| `ghn` | `cd ~/Github/n1ecC` |
| `ghr <repo>` | `cd` into a repo (no args = list) |
| `gho` / `ghab` / `ghdhs` / `ghtk` | Portfolio repo jumps |
| `ghex` / `ghws` / `ghcfg` / `ghroot` | explore / workspace / config / root |
| `ghsync` | Clone missing + pull all n1ecC repos |
| `ghsync-list` | Show clone status and dirty repos |
| `ghsync-pull` | Pull only |
| `ghar` | Archive a project to `archive/` |
| `ghpin` | Open GitHub profile pin instructions |

See `terminal-configs/SHORTCUTS.md` for the full reference.

---

## Daily workflow

```bash
ghsync-pull          # start of session
ghr olist-lakehouse  # work
git push origin main
```

---

## Conventions

1. Only `n1ecC/` gets pushed to your GitHub account
2. `explore/` is read-only — fork to `n1ecC/` if you keep changes
3. `workspace/` stays local until promoted to `n1ecC/`
4. Large datasets go in `workspace/datasets/` (gitignored)
5. Run `ghsync-pull` before interviews so portfolio repos are current
