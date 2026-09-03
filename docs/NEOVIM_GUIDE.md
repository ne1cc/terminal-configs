# Neovim Workflow Guide

Overview of the AstroNvim-based setup: navigation, fuzzy find, git integration, media, and LSP.

**Leader key:** `Space`  
**Config:** `.config/nvim/`

---

## Quick start

```bash
cd ~/Github/n1ecC/olist-lakehouse
nvim .
```

Essential first keys:

```
Space + e     toggle file tree (Neo-tree)
Space + ff    find file
Space + fg    live grep
Space + gg    Lazygit
gd            go to definition
K             hover docs
```

---

## Deep-dive guides

| Guide | Best for |
|-------|----------|
| [TELESCOPE_GUIDE.md](TELESCOPE_GUIDE.md) | Find files, grep, git branches, buffers (Snacks picker) |
| [10X_NEOVIM_SESSION.md](10X_NEOVIM_SESSION.md) | Walkthrough: orient, find code, trace bugs, edit |
| [LSP_SHORTCUTS.md](LSP_SHORTCUTS.md) | LSP navigation, diagnostics, rename, code actions |

This guide covers integrations and daily patterns; those two docs go deeper on session flow and LSP.

---

## Navigation model

Neovim shares tmux pane navigation — same keys everywhere:

| Key | Action |
|-----|--------|
| `Ctrl + h/j/k/l` | Move between splits / tmux panes |
| `Ctrl + \` | Previous split |
| `Space + z` | Maximize current window |
| `]b` / `[b` | Next / previous buffer |

**Jump pattern:** `gd` ? inspect ? `Ctrl + o` back — the most-used read workflow.

---

## File exploration

### Neo-tree sidebar

| Key | Action |
|-----|--------|
| `Space + e` | Toggle Neo-tree |
| `Space + o` | Toggle focus tree ? editor |
| `Enter` / `o` | Open file / expand dir |
| `P` | Floating preview |
| `M` | Open PDF in MuPDF |

### FzfLua picker

| Key | Action |
|-----|--------|
| `Space + ff` | Find files |
| `Space + fg` | Live grep (ripgrep) |
| `Space + fb` | Open buffers |
| `Space + fh` | Help tags |
| `Space + fs` | LSP document symbols |
| `Space + fr` | LSP references |
| `Ctrl + q` | Send all fzf results to quickfix |

Shell alternative: `fo` (fuzzy find ? bat preview ? nvim)

---

## Git integration

| Key | Action |
|-----|--------|
| `Space + gg` | Toggle floating Lazygit |
| `Space + gS` | Fugitive status (`:Git`) |
| `Space + gD` | Fugitive diff |
| `Space + gB` | Fugitive blame |
| `Space + gP` | Fugitive push |

See [LAZYGIT_GUIDE.md](LAZYGIT_GUIDE.md) for AI keys inside Lazygit.

**tmux:** `Prefix + Ctrl + g` opens Lazygit without leaving terminal layout.

---

## LSP essentials

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `grr` | Find references |
| `K` | Hover documentation |
| `grn` | Rename symbol (project-wide) |
| `gra` | Code actions |
| `[d` / `]d` | Previous / next diagnostic |
| `Space + ls` | Search symbols project-wide |
| `Space + lS` | Symbols outline (current file) |

Full table: [LSP_SHORTCUTS.md](LSP_SHORTCUTS.md)

---

## Markdown, images & documents

| Key | Action |
|-----|--------|
| `Space + p` | Paste image from clipboard into Markdown |
| `Space + ic` | Clear image overlay artifacts |
| `Space + ~` | Toggle strikethrough |
| `Space + op` | Open PDF (MuPDF) |
| `Space + oe` | Open EPUB (OmniReader) |
| `Space + mr` | Toggle Markdown Raw (As-Is: nowrap, conceal 0) / Rendered |
| `Space + mw` | Toggle soft wrap (Prose wrap vs Table nowrap view) |
| `Space + mz` | Fit viewport to full screen (closes sidebar, zooms tmux, nowrap) |
| `Space + mm` | Cycle Markdown display modes (Rendered wrap → Table nowrap → Raw as-is) |
| `Space + mp` | Markdown live browser preview (`markdown-preview.nvim`) |
| `Space + md` | Show diagram preview hover (clean floating window at cursor) |
| `Space + mb` | Toggle diagram in-buffer rendering (opaque background) |
| `Space + mx` | Toggle Markdown checklist item (`[ ]` → `[x]` → `[-]`) |
| `Space + mi` | Insert continuation list/numbered item |
| `Space + om` | Open Markdown (One Markdown) |
| `Space + mt` | Open Markdown (Mark Text) |
| `j` / `k` | Next/prev image in gallery buffer |

Inline image rendering via `3rd/image.nvim` + `img-clip.nvim` — optimized for Kitty/Ghostty graphics protocol.

---

## Insert / command mode

| Key | Action |
|-----|--------|
| `Alt + K` | Cut to end of line (clipboard) |
| `Ctrl + K` | Delete to end of line |

Matches shell `Alt + K` ergonomics.

---

## tmux integration

| tmux | Neovim |
|------|--------|
| `Prefix + Shift + O` | Jump to file:line from error on screen |
| `Prefix + D` | Dev layout — Neovim in 65% pane |
| `Ctrl + h/j/k/l` | Seamless pane navigation |

`tmux-open-path` extracts stack traces and compiler paths from terminal output ? opens in Neovim at the correct line.

---

## Daily workflows

### Open project and find code

See [10X_NEOVIM_SESSION.md](10X_NEOVIM_SESSION.md) Phase 1�3.

```bash
nvim .
Space + fs ? type function name ? Enter
gd ? trace definition
Ctrl + o ? jump back
```

### Fix diagnostic

```
]d              find next error
K               read hover
gra             pick quick-fix
Space + gD      review diff in Fugitive
```

### Document with screenshot

```
Space + p       paste screenshot into markdown
Space + om      preview in One Markdown
```

### Git commit from Neovim

```
Space + gg      Lazygit
Ctrl + A        AI commit message
P               push
```

---

## Plugins (high level)

| Plugin | Role |
|--------|------|
| AstroNvim | Base distribution, Tokyo Night theme |
| Neo-tree | File sidebar |
| FzfLua | Fuzzy finder |
| lazygit.nvim | Git TUI popup |
| Fugitive | Git commands |
| img-clip + image.nvim | Clipboard images in Markdown |
| LSP configs | Per-language servers via AstroNvim |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| LSP not attaching | `:LspInfo` or `Space + li` — install language server |
| Images garbled | `Space + ic` to clear overlays; use Ghostty/Kitty |
| Fzf empty | Must be inside project root with files |
| Lazygit won't open | Install `lazygit`; check `$PATH` |
| Slow startup | Run `:Lazy` to check plugin load; use `nvim --startuptime log` |

---

## Related docs

- [10X_NEOVIM_SESSION.md](10X_NEOVIM_SESSION.md)
- [LSP_SHORTCUTS.md](LSP_SHORTCUTS.md)
- [LAZYGIT_GUIDE.md](LAZYGIT_GUIDE.md)
- [TMUX_WORKFLOW_GUIDE.md](TMUX_WORKFLOW_GUIDE.md)
- [SHORTCUTS.md � 3](../SHORTCUTS.md)

---

## Cheat sheet

```
Tree:       Space+e  Space+o
Find:       Space+ff  Space+fg  Space+fs
LSP:        gd  grr  K  grn  gra  ]d
Git:        Space+gg  Space+gS  Space+gP
Media:      Space+p  Space+op  Space+om
Navigate:   Ctrl+h/j/k/l  Ctrl+o (back)
```
