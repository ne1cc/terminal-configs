# config/ — Dotfiles & Machine Configuration

Local machine setup, separate from portfolio repos in `../n1ecC/`.

## What lives here

| Path | Remote | Notes |
|------|--------|-------|
| `dotfiles/` | none (local) | Shell/editor config source files |
| `scripts/` | optional clone | Shared utility scripts |
| `analytics/` | none | Analytics / notebook configs |
| `docs/` | none | Local documentation |
| `external/` | none | Third-party config bundles |
| `local/` | none | Machine-specific overrides — never commit |

## What lives in n1ecC/

Repos you push to GitHub live in `../n1ecC/`:

- `terminal-configs` ? `../n1ecC/terminal-configs`
- All other n1ecC repos ? clone via `ghsync` / `sync-n1ecC`

## Symlinking dotfiles (optional)

If you want `~/.zshrc` to track files from here instead of `terminal-configs`:

```bash
ln -sf ~/Github/config/dotfiles/.zshrc ~/.zshrc
```

Only symlink what you actively maintain — don't symlink entire home directories.
