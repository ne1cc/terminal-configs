# Yazi File Manager Guide

Terminal file manager with optimized previews, MuPDF integration, and directory sync on exit.

**Launch:** `y` (shell wrapper) or `yazi`  
**Config:** `.config/yazi/yazi.toml`

---

## Quick start

```bash
cd ~/Github/n1ecC
y                     # browse files; exit returns to same directory
```

The `y` wrapper runs Yazi and `cd`s to whatever directory you were in when you quit — your shell `$PWD` follows Yazi navigation.

---

## Layout

Three-pane ratio `[0, 1, 4]`:

```
?????????????????????????????????????????????????
? (hidden) ?   file list     ?   preview pane   ?
?          ?                 ?   (bat/image/pdf)?
?????????????????????????????????????????????????
```

Preview pane gets most of the width for readable file previews.

---

## Navigation

| Key | Action |
|-----|--------|
| `h` | Parent directory |
| `j` / `k` | Down / up |
| `l` | Enter directory or open file |
| `Ctrl + u/d` | Half-page up/down |
| `Ctrl + b/f` | Full-page up/down |
| `gg` / `G` | Top / bottom of list |

---

## Preview

| Key | Action |
|-----|--------|
| `i` / `T` | Toggle full-screen preview |
| `e` | Toggle preview pane visibility |

### Performance tuning

Preview limits are optimized for Ghostty/Kitty graphics:

- `max_width: 2048`, `max_height: 1536` — reduces RGB transfer from ~65 MB to ~5–8 MB per frame
- `image_alloc: 512MB` — image preview cache
- `micro_workers: 10`, `macro_workers: 25` — parallel preview tasks

Result: near-instant previews on large images and PDFs.

---

## Opening files

| Key | Action |
|-----|--------|
| `o` / `O` / `Ctrl + o` | Open with interactive menu |
| `P` | macOS Quick Look (`qlmanage`) |
| `M` | Open in MuPDF |
| Enter on file | Default opener |

### Configured openers

| Rule | Opener chain |
|------|--------------|
| PDF | MuPDF ? macOS Open ? Quick Look |
| Video | Open ? terminal mpv |
| Default | `$EDITOR` (Neovim) for edit |

---

## Search

| Key | Action |
|-----|--------|
| `f f` | Fuzzy find filenames (fzf) |
| `f g` | Fuzzy find file contents (ripgrep + fzf) |
| `f s` | Live line search ? reveal match in Yazi |

---

## Sorting & display

Defaults (configurable in `yazi.toml`):

- Sort: alphabetical, directories first
- Hidden files: off (toggle in Yazi UI)
- Symlinks: shown

---

## Shell integration

```bash
# y() wrapper in .zshrc
y() {
  yazi "$@"
  cd "$(yazi --cwd-file)"
}
```

Always use `y` (not bare `yazi`) so your shell directory syncs on exit.

---

## Daily workflows

### Browse project structure

```bash
ghr olist-lakehouse
y
# navigate with j/k, preview with i
# q to quit ? shell stays in last directory
```

### Quick PDF review

```bash
y
# navigate to docs/
# M on any .pdf ? MuPDF
```

### Find file by content

```bash
y
f g
# type search term ? jump to file
```

### Open in Neovim

```bash
y
# l on file ? edit action
# or o ? pick "Edit" from menu
```

---

## Neovim & tmux

- Yazi complements Neo-tree (`<Leader>e` in Neovim) for terminal-only workflows
- Use Yazi when you want full-screen file browsing with rich previews
- Use Neo-tree when editing — sidebar stays visible

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Preview slow/laggy | Already tuned — reduce terminal size or disable image preview |
| `y` doesn't cd on exit | Use `y` wrapper, not raw `yazi` |
| MuPDF not opening | Install `mupdf` (`brew install mupdf`) |
| Quick Look fails | macOS only; use `o` ? Open on Linux |
| Hidden files missing | Toggle hidden in Yazi or set `show_hidden = true` |

---

## Related docs

- [ZSH_GIT_WORKFLOW_GUIDE.md](ZSH_GIT_WORKFLOW_GUIDE.md) — `y` launcher
- [NEOVIM_GUIDE.md](NEOVIM_GUIDE.md) — Neo-tree alternative
- [SHORTCUTS.md § 5](../SHORTCUTS.md) — full keybinding table

---

## Cheat sheet

```
Launch:     y
Navigate:   h j k l  gg G  Ctrl+u/d
Preview:    i T (fullscreen)  e (toggle pane)
Open:       o O  P (Quick Look)  M (MuPDF)
Search:     f f  f g  f s
Quit:       q (syncs cwd to shell)
```
