# LSP Shortcuts — Neovim (AstroNvim)

**Neovim overview:** [NEOVIM_GUIDE.md](NEOVIM_GUIDE.md) · **Session walkthrough:** [10X_NEOVIM_SESSION.md](10X_NEOVIM_SESSION.md)

## Navigation (jumping around code)

| Key       | Action                | Description                                       |
|-----------|-----------------------|---------------------------------------------------|
| `gd`      | Go to definition      | Jumps to where function/variable is defined       |
| `gD`      | Go to declaration     | Jumps to declaration                              |
| `gI`      | Go to implementation  | For abstract classes / protocols (→ concrete impl)|
| `grI`     | Go to type definition | Jumps to the TYPE of an expression                |
| `grr`     | Go to references      | List everything that uses this symbol             |
| `gO`      | Document symbols      | Outline view (functions/classes in THIS file)     |
| `<C-o>`   | Jump back             | Return to previous cursor position after a jump   |

## Search & Symbols (fuzzy picking)

| Key           | Action                    | Description                            |
|---------------|---------------------------|----------------------------------------|
| `<leader>ls`  | Search symbols            | Find function/class by name across project |
| `<leader>lD`  | Search diagnostics        | Fuzzy-search all errors/warnings       |
| `<leader>ff`  | Find files                | Fuzzy find any file in project         |
| `<leader>fO`  | Find old files (recents)  | Recently-opened files                  |
| `<leader>fg`  | Find in files (grep)      | Ripgrep live search                    |

## Renaming & Code Actions

| Key   | Action         | Description                                  |
|-------|----------------|----------------------------------------------|
| `grn` | Rename symbol  | Updates everywhere in project                |
| `gra` | Code actions   | Quick-fix imports, extract variable, etc.    |
| `R`   | Rename file    | Renames file + updates all imports           |

## Diagnostics (errors & warnings)

| Key       | Action                           |
|-----------|----------------------------------|
| `[d`      | Jump to previous diagnostic      |
| `]d`      | Jump to next diagnostic          |
| `[D`      | Jump to first diagnostic in file |
| `]D`      | Jump to last diagnostic in file  |
| `gl`      | Hover on current diagnostic (full error message) |
| `<C-W>d`  | Popup with diagnostic details    |

## Inspection (understanding code)

| Key          | Action                  |
|--------------|-------------------------|
| `K`          | Hover (type + docstring for symbol) |
| `<leader>ld` | Line diagnostics (all errors on current line) |
| `<leader>li` | LSP info (which LSP is attached + status) |
| `<leader>lS` | Symbols outline (tree on right side) |

## Toggle Features On/Off

| Key          | Action                         |
|--------------|--------------------------------|
| `<leader>uv` | Toggle virtual text            |
| `<leader>uV` | Toggle virtual lines           |
| `<leader>ud` | Toggle diagnostics visibility  |
| `<leader>uY` | Toggle semantic tokens         |
| `<leader>ur` | Toggle reference highlighting  |

## Advanced LSP Commands (via `:lua`)

```lua
-- Call Hierarchy
vim.lsp.buf.incoming_calls()     -- who calls this function?
vim.lsp.buf.outgoing_calls()     -- what does this function call?

-- Type Hierarchy
vim.lsp.buf.typehierarchy('supertypes')  -- parent classes
vim.lsp.buf.typehierarchy('subtypes')    -- child classes

-- Code Lens (clickable hints above functions: "3 references", "Run Tests")
-- Already enabled in AstroNvim

-- Organize Imports (auto-sort + clean up imports)
vim.lsp.buf.code_action({
  context = { only = { "source.organizeImports" } },
  apply = true
})
```

## Workflows in Practice

### Understand an unfamiliar function
```
K           → see signature + doc
gd          → jump to definition
<leader>lS  → see all functions in this file
grn         → rename it if needed
<C-o>       → jump back to where you came from
```

### Fix all errors in a file
```
]d          → jump to first error
gl          → read the error message
gra         → code action → "quick fix" / "import module"
]d          → next error
...repeat until clean
```

### Find where a function is used
```
grr         → all references
<CR>        → jump to a match
:copen      → open quickfix list as split window
:cclose     → close the quickfix list
:cnext      → next match
:cprev      → previous match
```

### Navigate a large class/module
```
<leader>lS  → opens outline on right side
j / k       → move up/down in outline
<CR>        → jump to that symbol
<leader>ls  → search all symbols in project
```
