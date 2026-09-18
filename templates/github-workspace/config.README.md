# config/ — Dotfiles & Machine Configuration

Local machine setup, separate from portfolio repos in `../ne1cc/`.

## What lives here

| Path | Remote | Notes |
|------|--------|-------|
| `dotfiles/` | none (local) | Shell/editor config source files |
| `scripts/` | optional clone | Shared utility scripts |
| `analytics/` | none | Analytics / notebook configs |
| `docs/` | none | Local documentation |
| `external/` | none | Third-party config bundles |
| `local/` | none | Machine-specific overrides — never commit |

## What lives in ne1cc/

Repos you push to GitHub live in `../ne1cc/`:

- `terminal-configs` ? `../ne1cc/terminal-configs`
- All other ne1cc repos ? clone via `ghsync` / `sync-ne1cc`

## Symlinking dotfiles (optional)

If you want `~/.zshrc` to track files from here instead of `terminal-configs`:

```bash
ln -sf ~/Github/config/dotfiles/.zshrc ~/.zshrc
```

Only symlink what you actively maintain — don't symlink entire home directories.
