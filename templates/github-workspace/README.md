# ~/Github — Development Workspace

Canonical home for all Git work on this machine.

**Path:** `~/Github` (capital `G` — same on macOS, Linux, and WSL)

---

## Folder layout

```
~/Github/
??? ne1cc/          # YOUR repos (github.com/ne1cc) — push from here
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
| `ghn` | `cd ~/Github/ne1cc` |
| `ghr <repo>` | `cd` into a repo (no args = list) |
| `gho` / `ghab` / `ghdhs` / `ghtk` | Portfolio repo jumps |
| `ghex` / `ghws` / `ghcfg` / `ghroot` | explore / workspace / config / root |
| `ghsync` | Clone missing + pull all ne1cc repos |
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

1. Only `ne1cc/` gets pushed to your GitHub account
2. `explore/` is read-only — fork to `ne1cc/` if you keep changes
3. `workspace/` stays local until promoted to `ne1cc/`
4. Large datasets go in `workspace/datasets/` (gitignored)
5. Run `ghsync-pull` before interviews so portfolio repos are current
