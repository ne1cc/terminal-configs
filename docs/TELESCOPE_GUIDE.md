# Fuzzy Finder Guide (Snacks Picker)

How to find files, grep text, switch git branches, and jump between buffers in Neovim.

**Leader key:** `Space`  
**Config:** `.config/nvim/` (AstroNvim v6)

> **Note:** AstroNvim v6 uses **Snacks picker** (`folke/snacks.nvim`) for most find operations. It looks and behaves like Telescope — fuzzy list, live filter, preview pane — but the default engine changed. Telescope is still installed for extras (file browser, TODO search). Keys below target **your current setup**.

---

## Quick start

```
Space + ff     find file by name
Space + fw     search text inside files (ripgrep)
Space + fs     smart find (files + buffers + recents)
Space + fb     open buffers
Space + gb     git branches
Esc / q        close any picker
```

Press `Space` and pause — **which-key** shows the full menu.

---

## Universal picker controls

These work in **every** picker (files, grep, git, buffers, etc.):

| Key | Action |
|-----|--------|
| **Type** | Filter results (starts in insert mode) |
| `j` / `k` | Move down / up |
| `Ctrl+j` / `Ctrl+k` | Move down / up |
| `Ctrl+p` / `Ctrl+n` | Move down / up |
| `Enter` | Select / confirm |
| `Esc` or `q` | Close without selecting |
| `Ctrl+c` | Cancel (from insert mode) |
| `Tab` / `Shift+Tab` | Next / previous match |
| `?` | Show picker-specific help |

### Open in split or tab

| Key | Action |
|-----|--------|
| `Ctrl+s` | Open in horizontal split |
| `Ctrl+v` | Open in vertical split |
| `Ctrl+t` | Open in new tab |
| `Shift+Enter` | Pick window, then jump |

### Toggles (prompt bar icons)

| Key | Action |
|-----|--------|
| `Alt+h` | Toggle hidden files |
| `Alt+i` | Toggle gitignored files |
| `Alt+p` | Toggle preview pane |
| `Alt+r` | Toggle regex search mode |
| `Alt+f` | Toggle follow (live update) |

---

## Find pickers (`Space + f…`)

Press `Space + f` to open the find submenu, or use these directly:

| Key | What it finds |
|-----|----------------|
| `Space + ff` | **Files** in project (most used) |
| `Space + fw` | **Text inside files** (live grep; needs `rg`) |
| `Space + fW` | Grep including hidden/ignored files |
| `Space + fs` | **Smart** — files + buffers + recents |
| `Space + fb` | Open **buffers** |
| `Space + fo` | **Recent** files (global) |
| `Space + fO` | Recent files (current project only) |
| `Space + fg` | Git-tracked files only |
| `Space + fF` | All files (hidden + ignored) |
| `Space + fc` | Grep for word **under cursor** |
| `Space + fk` | Keymaps (discover bindings) |
| `Space + fh` | Help tags |
| `Space + fC` | Ex commands |
| `Space + fp` | Projects |
| `Space + f'` | Marks |
| `Space + fr` | Registers |
| `Space + fu` | Undo history |
| `Space + fT` | TODO comments |
| `Space + fCR` | **Resume** last search |

---

## Git pickers (`Space + g…`)

| Key | What it does |
|-----|----------------|
| `Space + gb` | **Git branches** — switch, create, delete |
| `Space + gt` | Git status (changed files) |
| `Space + gc` | Git log (whole repo) |
| `Space + gC` | Git log (current file) |
| `Space + gT` | Git stash |

### Git branches picker (`Space + gb`)

| Key | Action |
|-----|--------|
| `Enter` | Checkout selected branch |
| `Ctrl+a` | Create new branch |
| `Ctrl+x` | Delete branch |
| `Esc` | Close without switching |

Preview pane on the right shows recent commits for the highlighted branch.

For full git UI (stage, commit, push): `Space + gg` (Lazygit). See [LAZYGIT_GUIDE.md](LAZYGIT_GUIDE.md).

---

## Daily workflows

### “I know part of the filename”

```
Space + ff → type "polytime" → Enter
```

Fuzzy matching — `"plt"` often finds `polytime`.

### “I know text inside the file”

```
Space + fw → type "fix(macos)" → Enter
```

Searches file **contents**, not filenames. Requires [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`).

### “I had it open recently”

```
Space + fo
```

Or `Space + fs` for the combined smart picker.

### “Which files are open right now?”

```
Space + fb
```

Jump between buffers without closing anything.

### “Switch git branch”

```
Space + gb → pick branch → Enter
```

### “Where is this function defined?”

Use LSP, not the fuzzy finder:

```
gd          go to definition
Space + ls  search symbols project-wide
```

See [LSP_SHORTCUTS.md](LSP_SHORTCUTS.md).

---

## Snacks vs Harpoon vs `:e`

| Tool | When to use |
|------|-------------|
| **Snacks** (`Space + f…`) | Find any file, grep, git, buffers — **exploration** |
| **Harpoon** (`Space + h1`–`h4`) | Same 2–4 files all day — **working set** |
| **`:e path`** | You know the exact path |
| **Neo-tree** (`Space + e`) | Browse folder structure visually |

### Harpoon quick reference

| Key | Action |
|-----|--------|
| `Space + a` | Bookmark current file |
| `Space + h1`–`h4` | Jump to slot 1–4 |
| `Space + hm` | Menu (view, reorder, remove) |

---

## Telescope (legacy / extras)

Telescope is still available for some pickers. Examples:

```vim
:Telescope file_browser
:TodoTelescope
```

Most daily finding should use Snacks (`Space + f…`) instead.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Space + fw` does nothing | Install ripgrep: `brew install ripgrep` |
| Picker feels slow on huge repo | Use `Space + fg` (git files only) or grep with a tighter query |
| Forgot a binding | `Space + fk` or press `?` inside any picker |
| Want to repeat last search | `Space + f` then `Enter` (`Space + fCR`) |

---

## Related guides

| Guide | Best for |
|-------|----------|
| [NEOVIM_GUIDE.md](NEOVIM_GUIDE.md) | Overview, navigation, integrations |
| [10X_NEOVIM_SESSION.md](10X_NEOVIM_SESSION.md) | End-to-end session walkthrough |
| [LSP_SHORTCUTS.md](LSP_SHORTCUTS.md) | Go-to-def, references, rename |
| [LAZYGIT_GUIDE.md](LAZYGIT_GUIDE.md) | Full git TUI inside nvim |

---

## One-page cheat sheet

```
FIND FILE        Space + ff     type → Enter
FIND IN TEXT     Space + fw     type → Enter
SMART FIND       Space + fs
BUFFERS          Space + fb
RECENT           Space + fo
GIT BRANCHES     Space + gb
RESUME SEARCH    Space + f + Enter
KEYMAPS          Space + fk

INSIDE PICKER:
  Enter          select
  Esc / q        close
  Ctrl+s / v     split / vsplit
  Ctrl+t         new tab
  ?              help
```
