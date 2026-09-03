# Lazygit Guide

Git TUI with Tokyo Night theme, Delta diffs, AI-assisted commits, and GitHub CLI integration.

**Launch:** `lg` (current repo) · `lgd` (dotfiles) · `Prefix + Ctrl + g` (tmux floating modal)

**Config:** `.config/lazygit/config.yml`

---

## Quick start

```bash
cd ~/Github/n1ecC/olist-lakehouse
lg
```

Inside Lazygit:

1. Stage files with `space`
2. Press `Ctrl + A` ? Antigravity generates commit message
3. Press `C` ? Claude reviews staged diff
4. Press `N` ? create GitHub PR

---

## Interface overview

Lazygit panels (typical layout):

```
?? Status (files) ??????? Diff preview ??????
?  staged / unstaged   ?  selected file diff ?
?? Branches ????????????                     ?
?  local / remote      ?                     ?
?? Commits ?????????????                     ?
??????????????????????????????????????????????
```

- **Files panel** — stage/unstage, view diffs
- **Branches panel** — checkout, merge, rebase
- **Commits panel** — browse history, cherry-pick, reset

Navigation uses Vim-style keys by default. Press `?` inside Lazygit for built-in help.

---

## Theme & diff

Configured for Tokyo Night palette with **Delta** as the pager:

- Active border: `#7dcfff`
- Unstaged changes: `#f7768e`
- Selected line: `#2d3149`

Diffs render with syntax highlighting via `delta --dark --paging=never`.

Files open in Neovim: `nvim +{line} {file}`

---

## AI custom commands

Available when files or branches are selected:

| Key | Tool | Context | Action |
|-----|------|---------|--------|
| `Ctrl + A` | Antigravity | files | Generate conventional commit message from staged changes |
| `C` | Claude | files | Review staged diff for bugs, edge cases, performance |
| `X` | Codex | localBranches | Explain architecture impact of branch changes |
| `Q` | Qoder | files | Audit staged changes for compliance/safety |

### Commit workflow with AI

```
1. Stage changes (space on files)
2. Ctrl + A  ? read suggested commit title/body
3. C         ? optional review before committing
4. c         ? commit (standard Lazygit)
5. P         ? push
6. N         ? create PR via gh
```

---

## GitHub CLI integration

| Key | Context | Action |
|-----|---------|--------|
| `N` | global | `gh pr create --fill` |
| `O` | localBranches | `gh pr checkout <branch>` |

Requires `gh auth login`.

---

## Clipboard commands

| Key | Context | Action |
|-----|---------|--------|
| `Ctrl + Y` | files / commitFiles | Copy full file contents |
| `Y` | files | Copy unstaged diff patch |
| `Y` | commitFiles | Copy commit file patch |

Uses `pbcopy` (macOS) or `xclip`/`xsel` (Linux).

---

## Destructive operations

| Key | Context | Action |
|-----|---------|--------|
| `d` | commits | Hard reset to parent of selected commit (with confirmation) |

**Warning:** This permanently drops the selected commit.

---

## tmux integration

`Prefix + Ctrl + g` opens Lazygit in a **centered 90% floating popup** — stays over your editor/shell layout.

From Neovim: `<Leader>gg` or `<Leader><Ctrl-g>` toggles Lazygit via `lazygit.nvim`.

---

## Shell aliases

| Alias | Action |
|-------|--------|
| `lg` | Lazygit in `$PWD` |
| `lgd` | Lazygit in dotfiles (`$DOTFILES`) |

---

## Daily workflows

### Review before push

```bash
lg
# ? files panel: review unstaged
# ? C: Claude review
# ? stage ? commit ? P push
```

### Create PR from feature branch

```bash
lg
# ? checkout feature branch
# ? N: gh pr create --fill
```

### Inspect branch impact

```bash
lg
# ? branches panel ? select branch
# ? X: Codex architecture analysis
```

### Checkout someone's PR

```bash
lg
# ? branches ? select branch
# ? O: gh pr checkout
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| AI key does nothing | Ensure `agy`, `claude`, `codex`, `qodercli` on `$PATH` |
| PR create fails | `gh auth login`; must be inside git repo with remote |
| Delta not coloring | Install `git-delta`; check `git.pagers` in config |
| Opens wrong editor | Config sets `nvim` — set `$EDITOR` if needed |
| Popup too small in tmux | Resize terminal; popup is 90% of current dimensions |

---

## Related docs

- [AI_WORKFLOW_GUIDE.md](AI_WORKFLOW_GUIDE.md) — Claude, Antigravity, handoffs
- [ZSH_GIT_WORKFLOW_GUIDE.md](ZSH_GIT_WORKFLOW_GUIDE.md) — shell git aliases
- [TMUX_WORKFLOW_GUIDE.md](TMUX_WORKFLOW_GUIDE.md) — floating Lazygit binding

---

## Cheat sheet

```
Launch:     lg  lgd  Prefix+Ctrl+g
AI:         Ctrl+A (commit)  C (review)  X (branch)  Q (audit)
GitHub:     N (create PR)  O (checkout PR)
Clipboard:  Ctrl+Y (file)  Y (diff)
Danger:     d on commits (hard reset)
```
