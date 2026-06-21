# 10x Neovim Session Walkthrough

## Phase 1: Launch & Get Oriented (5 seconds)

```bash
cd ~/Github/2026/some-project
nvim .
```

Neovim opens with the tree visible on the left (`<leader>e` toggles it). Home screen shows recent files for this directory.

**Move fast:**
```
<leader>e        → toggle tree back on if it closed
<leader>fo       → recent files — "I was working on settings.py yesterday"
<leader>fO       → recent files in THIS directory only
<leader>fs       → "smart find" — search across files, buffers, recent, all at once
```

If you remember the filename: `<leader>ff` and type 3 letters of it.

---

## Phase 2: Find the Code You Care About

**Scenario A: "I know the function name"**
```
<leader>ls    → search symbols across project
type "Settings" → see `class Settings` in `pipeline/config/settings.py`
<CR>          → jumps you there
```

**Scenario B: "I know what string/value to grep"**
```
<leader>fw    → live grep (ripgrep-backed, live results)
type "MONGODB_URI" → see every file containing that string
arrow keys + <CR> → jump to match
```

**Scenario C: "I remember nothing, just show me what's here"**
```
<leader>ff    → browse all files, type a partial path
<leader>lS    → symbols outline on right side — see all classes/functions in open file
<leader>fT    → find all TODO/FIXME comments
```

---

## Phase 3: Read Unfamiliar Code Fast

You're in a file you've never seen. Here's how a senior dev reads it in 30 seconds:

```
1. <leader>lS     → symbols outline (right side). Scan the structure.
                    See class names, method signatures, the shape of the module.

2. j/k            → scroll through. Don't read every line. Look for:
                    - function signatures (types tell you everything)
                    - comments / docstrings
                    - obvious entry points like `main()`, `__init__`

3. Place cursor on anything interesting:
   K              → hover: see type signature + docstring popup
   gd             → jump to definition of this function/class
   grr            → see every place this symbol is referenced
   gri            → implementations (for protocols/abstract classes)
```

**After jumping with `gd`, come back with:**
```
<C-o>            → jump back to where you were before
<C-i>            → jump forward again (undo the back-jump)
```

This is the most-used pattern in a senior dev's day: **jump in, inspect, jump out.**

---

## Phase 4: Trace a Bug End-to-End

Someone says "the API returns 500 on /api/v1/prices". Your workflow:

```
1. <leader>fw    → grep "prices" → find the route handler
2. <CR>          → land in the handler function
3. K             → hover over the service call to see its signature
4. gd            → jump into the service function
5. grr           → "who else calls this?" — see if it's used elsewhere
6. ]d [d         → jump between diagnostics in this file (is anything flagged?)
7. gl            → read the full error message under cursor
```

**If it's a real error:**
```
gra              → code action → "quick fix" / "add import" / "add type hint"
grn              → rename the thing you misnamed
```

**If you need to test a fix:**
```
<F7> or <C-'>    → open inline terminal
type command     → run tests, see output, close terminal
```

You never left Neovim. The whole trace happened in one window.

---

## Phase 5: Renaming Across the Project

Found a variable you want to rename (e.g., `db` → `database`):

```
1. cursor on `db`
2. grn             → rename symbol
3. type "database" → <CR>
4. :wa             → save ALL modified buffers
5. :LazyCheck      → (or just check statusline) — see diagnostics update
```

Every reference across every file is updated atomically.

---

## Phase 6: Navigate Between Files Without Losing Place

You're juggling 4 files. Here's how you flip:

```
[b / ]b            → previous / next buffer (in tabline order)
<leader>fb         → fuzzy-find among open buffers
<leader>fs         → smart find — buffers + recent + files
<C-o>              → jump back to last cursor position
<C-i>              → jump forward
```

**For git navigation:**
```
]q [q              → next/prev quickfix entry (use after grep)
]T [T              → next/prev TODO comment in file
]t [t              → next/prev tab
```

---

## Phase 7: Split Views (When You Need Two Files)

```
\                  → horizontal split
|                  → vertical split
<C-h> <C-j> <C-k> <C-l>  → move between splits
<C-up/down/left/right>   → resize splits
```

Typical use: open the file you're editing on top, the test file (or docs) on the bottom.

---

## Phase 8: Session Management (Don't Lose State)

```
<leader>Ss         → save this session (all open buffers, splits, cursor positions)
<leader>Sf         → load a saved session
<leader>S.         → load the session for THIS directory
<leader>SD         → delete a named session
```

Use this when switching between projects. Save your state before you `cd` out.

---

## Phase 9: Git Without Leaving Neovim

```
<leader>gt         → git status (fugitive)
<leader>gc         → git log (browse commits)
<leader>gC         → git log for current file only
<leader>gb         → git branches
<leader>gT         → git stash
```

In fugitive status screen, `dd` stages a file, `cc` commits, `DV` diffs vertically.

---

## The Mental Model

The speed isn't from memorizing 200 shortcuts. It's from chaining these patterns:

```
FIND     → EDIT    → INSPECT  → NAVIGATE
<leader>ff   gra/grn           K/gd/grr         <C-o> / ]b / <leader>fb
<leader>fw   i (insert mode)   ]d / gl          <leader>fs
<leader>ls   cc (comment)      grt / gri        <leader>lS
```

A junior dev opens VS Code, clicks around, alt-tabs to terminal, alt-tabs back.
A senior dev:
1. Opens one window
2. Finds the file in 2 keystrokes
3. Jumps to the definition in 2 keystrokes
4. Renames the symbol across 10 files in 3 keystrokes
5. Runs tests in an inline terminal
6. Never touches the mouse

---

## The Real Multipliers

The 10x effect comes from removing friction, not adding speed. Specifically:

1. **Never leaving the keyboard** — everything is a key combo
2. **Never guessing** — K / gd / grr give you instant answers about code
3. **Never losing place** — `<C-o>`, sessions, buffer navigation
4. **Never context-switching** — terminal, editor, git, LSP, all in one pane
5. **Never typing the same thing twice** — snippets, renames, code actions

The tools are just leverage. The 10x is the *habit* of never doing anything the hard way twice.
