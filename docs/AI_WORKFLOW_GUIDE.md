# AI Workflow Guide

Claude Code, Antigravity (Gemini CLI), Lazygit AI integrations, agent matrix, and session handoffs.

---

## Quick start

```bash
# Claude Code — interactive
claude

# Shell shortcuts
cplan "add DuckDB export to reporting pipeline"
creview
cgc                              # generate commit message from diff

# Antigravity
agy
agyy                             # YOLO mode (skip tool approvals)

# Session handoff for resume
handoff "finished dbt model tests"

# tmux
Prefix + a                       # Claude popup
Prefix + Alt + y                   # Antigravity popup
Prefix + Ctrl + t                  # agent matrix
Prefix + Shift + H                 # handoff
```

---

## Three AI layers

| Layer | Tool | Best for |
|-------|------|----------|
| **Interactive terminal** | `claude`, `agy` | Pair programming, exploration |
| **Shell one-shots** | `cplan`, `creview`, `cgc`, `cbug` | Quick tasks from zsh |
| **Git TUI** | Lazygit custom keys | Commit messages, diff review in git flow |
| **Slash commands** | `/plan`, `/cook`, `/continue`, `/release` | Structured project workflows |

---

## Claude Code

### Interactive

```bash
claude                           # start session in $PWD
cco "explain this module"          # alias wrapper
```

### Shell aliases (`.zshrc`)

| Alias | Action |
|-------|--------|
| `cco [msg]` | Pass prompt to Claude |
| `cinit` | Create starter `CLAUDE.md` |
| `cbug [desc]` | Debug clipboard contents (stack trace) |
| `creview` | Review unstaged/staged git diff |
| `cplan <task>` | Generate implementation plan |
| `cdoc <file>` | Generate docs for a file |
| `ctest <file>` | Generate unit tests for a file |
| `cgc` | Generate conventional commit + commit |

### Examples

```bash
# Paste error from clipboard, get diagnosis
# (copy stack trace first)
cbug

# Review before committing
creview

# Auto-commit with AI message
git add -A
cgc
```

### Global configuration

Symlinked by `install.sh`:

- `~/.claude/CLAUDE.md` ? `claude-code/CLAUDE.md` (MSTSPAT standards)
- `~/.claude/commands/` ? slash commands

---

## Claude Code slash commands

Available in any Claude Code session (symlinked globally):

| Command | Purpose |
|---------|---------|
| `/plan [context]` | Analyze docs ? create/update `TODO.md` roadmap |
| `/cook [context]` | Execute tasks from `TODO.md` systematically |
| `/continue [context]` | Resume interrupted work from git + TODO state |
| `/release [context]` | Lint, test, version bump, tag, push |
| `/tech-dd [context]` | Technical due diligence report |

**Workflow chain:**

```
/plan ? /cook ? (interrupt) ? /continue ? /release
```

Full details: [claude-code/commands/README.md](../claude-code/commands/README.md)

### MSTSPAT standard (enforced in CLAUDE.md)

- **M**inimal — only necessary code
- **S**elf-documenting — precise naming
- **T**ype-exact — no `any`, full validation
- **S**ecure — input validation, env vars for secrets
- **P**erformant — framework best practices
- **A**ccessible — when UI applies
- **T**estable — meaningful coverage

---

## Antigravity (Gemini CLI)

### Commands

| Alias | Action |
|-------|--------|
| `agy` | Run Antigravity CLI |
| `agy-yolo` / `agyy` / `yolo` | Skip tool approval prompts |

### Audit ledger

Antigravity writes session history to `~/.gemini_history.md`.

| Alias | Action |
|-------|--------|
| `glog` | Markdown preview of audit ledger |
| `gdiff` | Side-by-side diff of session history |
| `agya` | Export latest audit report |
| `agyih` | Interactive full session history viewer |

### Skills

100+ specialized skills live in `.gemini/skills/` — data engineering, document processing, code review, etc. Skills activate contextually when using Antigravity.

Global rules: `.gemini/GEMINI.md`

---

## Lazygit AI integration

Launch: `lg` or `Prefix + Ctrl + g`

| Key | AI tool | Action |
|-----|---------|--------|
| `Ctrl + A` | Antigravity | Conventional commit message from staged changes |
| `C` | Claude | Review staged diff for bugs |
| `X` | Codex | Analyze branch architecture impact |
| `Q` | Qoder | Audit staged changes |
| `N` | GitHub CLI | Create PR (`gh pr create --fill`) |
| `O` | GitHub CLI | Checkout PR for branch |

See [LAZYGIT_GUIDE.md](LAZYGIT_GUIDE.md) for clipboard keys and theme.

---

## tmux AI layouts

| Trigger | Layout |
|---------|--------|
| `Prefix + a` | Centered Claude popup (persistent session) |
| `Prefix + Ctrl + p` | Project-specific Claude popup |
| `Prefix + Shift + A` | Side-by-side Claude (35%) |
| `Prefix + Ctrl + c` | Full window Claude |
| `Prefix + Alt + y` | Antigravity YOLO popup |
| `Prefix + Ctrl + t` | Agent matrix (2/3/4 agents) |
| `tmux-workspace ai` | Editor + Claude split |

### Agent matrix

```bash
matrix 2     # 2 parallel agents
matrix 3     # 3 agents
matrix 4     # 4 agents tiled
```

Or `Prefix + Ctrl + t` ? pick layout in fzf modal.

---

## Session handoff

Capture state for AI resume across sessions or machines.

### Shell

```bash
handoff                          # auto-topic from tmux/git/cwd
handoff "dbt-models-refactor"    # named topic
handoff "CI fix" "blocked on billing"
```

Aliases: `aghandoff`, `ag-handoff`

### tmux

`Prefix + Shift + H` ? runs `session-handoff`

### Output locations

| Path | When |
|------|------|
| `.gemini/sessions/YYYY-MM-DD-<topic>.md` | Inside git repo |
| `.gemini/sessions/latest.md` | Symlink to latest |
| `~/.gemini/sessions/latest.md` | Global fallback |
| `.claude/memory/sessions/` | Claude-compatible copy |

### Handoff contents

- Git branch, upstream, recent commits
- `git status -sb`, diff stats (staged + unstaged)
- Toolchain versions (Node, Python, Rust, Go)
- Active virtualenv
- Listening ports
- Tmux session/window/pane info
- Resume prompt template

---

## Git worktrees + AI

Parallel AI sessions on separate branches:

```bash
wt-new ai-refactor               # shell
# or Prefix + Ctrl + n           # tmux ? prompts branch ? opens Claude window
```

Pick existing worktree: `Prefix + Ctrl + a` or `wt-tmux-attach`

Remove when done: `Prefix + Ctrl + x` or `wt-rm`

---

## Cursor & Claude skills (IDE)

Cursor agent skills symlinked via `link-agent-skills.sh`:

- `review-bugbot`, `review-security` — code review
- `babysit` — PR merge-ready loop
- `loop` — recurring prompts
- `sdk` — Cursor SDK automation
- `share`, `new-repo`, `origin` — repo management

Claude Code skill: `delegate-agy` — delegate to Antigravity CLI

---

## Daily workflows

### Plan ? implement ? commit

```bash
claude
/plan "add SRM check to ab-testing pipeline"
/cook
# ... when done ...
/release
```

### Quick fix with shell aliases

```bash
cplan "fix SQLFluff ordering in CI"
# implement manually or with claude
creview
git add -A && cgc
git push
```

### Antigravity audit trail

```bash
agyy                             # YOLO session
# ... work ...
agya                             # export audit report
glog                             # preview ledger
```

### End session — hand off to tomorrow

```bash
handoff "olist promote_run fix"
# or Prefix + Shift + H
```

Tomorrow:

```bash
agy
# "Resume from .gemini/sessions/latest.md"
```

### Parallel agents on large refactor

```bash
Prefix + Ctrl + t    # pick 3-agent matrix
# or: matrix 3
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `claude` not found | Install Claude Code CLI; check `$PATH` |
| `agy` not found | Install Antigravity CLI |
| Slash commands missing | Run `./install.sh` to symlink `~/.claude/commands/` |
| Lazygit AI key fails | Ensure `claude`, `agy`, `codex` on `$PATH` |
| Handoff empty git section | Must run inside git repo |
| YOLO mode too aggressive | Use `agy` without `--dangerously-skip-permissions` |

---

## Cheat sheet

```
Claude:       claude  cplan  creview  cgc  cbug  cinit
Slash:        /plan  /cook  /continue  /release  /tech-dd
Antigravity:  agy  agyy  glog  gdiff  agya  agyih
Handoff:      handoff  Prefix+Shift+H
tmux AI:      Prefix+a  Prefix+Alt+y  Prefix+Ctrl+t
Lazygit:      lg ? Ctrl+A  C  X  Q  N  O
```
