# Production Multi-Agent Git Worktree Swarm Orchestrator (`fleet`)

`fleet` is an enterprise-grade CLI orchestrator and Zsh workflow layer designed to parallelize problem solving across three cutting-edge terminal AI agents:
1. **`claude`** (Anthropic Claude Code)
2. **`agy`** (Google Antigravity CLI)
3. **`qodercli` / `qoder`** (Qoder AI Terminal Assistant)

---

## 1. System Architecture & Topology

```
                  ┌──────────────────────────────────────────────┐
                  │          Main Repository (Parent)            │
                  │  Base Branch: main / feature (Clean/Snapshot)│
                  └──────────────────────┬───────────────────────┘
                                         │
                                         ▼
                      git worktree add (Isolated Branches)
         ┌───────────────────────────────┼───────────────────────────────┐
         │                               │                               │
         ▼                               ▼                               ▼
┌──────────────────┐           ┌──────────────────┐           ┌──────────────────┐
│  .worktrees/     │           │  .worktrees/     │           │  .worktrees/     │
│  <run-id>/claude │           │  <run-id>/agy    │           │  <run-id>/qoder  │
│                  │           │                  │           │                  │
│ Branch:          │           │ Branch:          │           │ Branch:          │
│ fleet/<id>/claude│           │ fleet/<id>/agy   │           │ fleet/<id>/qoder │
│                  │           │                  │           │                  │
│ Port: :3101      │           │ Port: :3102      │           │ Port: :3103      │
└────────┬─────────┘           └────────┬─────────┘           └────────┬─────────┘
         │                              │                              │
         └──────────────────────────────┼──────────────────────────────┘
                                        │
                                        ▼
                  ┌──────────────────────────────────────────────┐
                  │             Tmux Session: fleet-<run-id>     │
                  │  [1: claude (:3101)] [2: agy (:3102)] [3: qoder (:3103)]
                  └──────────────────────────────────────────────┘
```

---

## 2. Hardened Edge-Case Mechanics

| Edge Case | Problem | Fleet Production Solution |
|---|---|---|
| **Uncommitted Index Pollution** | Running parallel agents on a dirty worktree can corrupt or collide staging. | Automatic snapshot commits (`--snapshot`), auto-stashing (`--stash`), or clean aborts (`--clean`). |
| **Cold-Start Build & Dependency Isolation** | Concurrent `npm install` or symlink write collisions crash builds. | Deterministic dependency modes (`--deps=symlink\|install\|none`), auto-copying secrets (`.env*`, `local.settings.json`, `.npmrc`), and concurrent background package manager execution. |
| **Port Allocation Clashing** | Multiple agents spinning up dev servers collide on `:3000`. | Automatic deterministic port offsets injected into pane environments: `PORT=3101`, `3102`, `3103` (`VITE_PORT`, `NEXT_PORT`, `SERVER_PORT`, `FLASK_RUN_PORT`, `UVICORN_PORT`). |
| **Process Lifecycle & Detached Worktrees** | Abrupt terminal crashes leave dangling worktree locks (`.git/worktrees/*`). | Built-in self-healing lock recovery routine (`fleet doctor` / `heal_worktree_locks`), automated worktree pruning, and clean teardown. |

---

## 3. CLI Command Reference

### `fleet spawn <run-id> [options]`
Provisions isolated Git worktrees, configures the Tmux session, injects environment variables, launches all 3 AI agents, and broadcasts the initial prompt.

```bash
# Basic spawn with prompt
fleet spawn navbar-refactor -p "Implement a responsive navigation bar with dark mode in Tailwind CSS"

# Spawn from custom base branch with non-interactive mode
fleet spawn auth-v2 --base feat/core-api -p "Add OAuth2 PKCE flow" -y

# Spawn using dependency installation
fleet spawn data-pipeline -d install -p "Set up DuckDB ETL pipeline"
```

**Options:**
- `-p, --prompt "<text>"`: Initial prompt injected into all agent processes.
- `-P, --prompt-file <file>`: Read initial prompt from a file.
- `-b, --base <branch>`: Base branch to branch from (default: current HEAD).
- `-d, --deps <mode>`: Dependency mode: `symlink` (default), `install`, or `none`.
- `--stash`: Auto-stash uncommitted changes before spawn and pop back on parent.
- `--snapshot`: Create ephemeral snapshot commit for dirty working copy without altering parent.
- `--clean`: Abort if uncommitted changes exist.
- `--agents <csv>`: Comma-separated list of agents (default: `claude,agy,qoder`).
- `-l, --layout <layout>`: Layout geometry (`even-horizontal`, `main-horizontal`, `tiled`).
- `--port-base <port>`: Base port offset (default: `3100`).
- `--no-attach`: Do not automatically attach to the Tmux session.

---

### `fleet broadcast <run-id> "<prompt>"`
Broadcasts prompt instructions simultaneously to all (or filtered) agent panes in the target Tmux session.

```bash
# Broadcast to all agents
fleet broadcast navbar-refactor "Make sure the mobile drawer closes on ESC key press"

# Target specific agent
fleet broadcast navbar-refactor -a agy "Add unit tests in Jest"
```

---

### `fleet diff <run-id> [options]`
Renders a comparison matrix showing commits ahead, changed file counts, line additions/deletions, and dev server URLs.

```bash
# Matrix overview
fleet diff navbar-refactor

# Detailed diffstat
fleet diff navbar-refactor --stat

# Full colored patch diff
fleet diff navbar-refactor --patch
```

---

### `fleet keep <run-id> <winning-agent> [options]`
Promotes the winning solution, integrates it into the base branch, and tears down losing worktrees and branches.

```bash
# Merge winning branch into base branch and teardown
fleet keep navbar-refactor agy --merge

# Fast-forward rebase into base branch
fleet keep navbar-refactor claude --rebase

# Push and create a GitHub Pull Request
fleet keep navbar-refactor qoder --pr
```

---

### `fleet kill <run-id> [options]`
Gracefully terminates processes, destroys the Tmux session, removes worktrees, prunes Git metadata, and deletes ephemeral branches.

```bash
# Complete teardown
fleet kill navbar-refactor

# Teardown while keeping Git branches for manual review
fleet kill navbar-refactor --keep-branches
```

---

### `fleet ls`
Lists all active fleet sessions, associated worktrees, disk footprints, and process states.

```bash
fleet ls
```

---

### `fleet doctor`
Runs health checks across system binaries (`git`, `tmux`, `claude`, `agy`, `qodercli`, `gh`), repairs stale worktree locks, and cleans up orphaned metadata.

```bash
fleet doctor
```

---

## 4. Shell Integration & Aliases

Add the following to your shell configuration (pre-configured in [`.zshrc`](file:///Users/alex/Github/ne1cc/terminal-configs/.zshrc)):

| Alias | Command | Purpose |
|---|---|---|
| `fsp` | `fleet spawn` | Spawn parallel swarm |
| `fbc` | `fleet broadcast` | Broadcast prompt to agents |
| `fkp` | `fleet keep` | Promote winner & teardown |
| `fdf` | `fleet diff` | Inspect comparison matrix |
| `fkl` | `fleet kill` | Terminate run & clean worktrees |
| `fls` | `fleet ls` | List active swarms |
| `fdoc` | `fleet doctor` | Self-healing diagnostics |
| `fat` | `fleet attach` | Attach to active swarm |
| `flog` | `fleet logs` | View recent pane logs |
| `fsel` | `fsel` | Fuzzy interactive swarm selector |
| `fzf-diff` | `fzf-diff` | Fuzzy diff inspector |

---

## 5. Configuration (`.config/fleet/fleet.conf`)

Fleet automatically looks for configuration in:
1. `--config <path>`
2. `<repo-root>/config/fleet.conf`
3. `~/.config/fleet/fleet.conf`

```bash
DEFAULT_AGENTS="claude,agy,qoder"
PORT_BASE=3100
DEPS_STRATEGY="symlink"
TMUX_LAYOUT="even-horizontal"
AUTO_STASH="prompt"
CLAUDE_CMD="claude"
AGY_CMD="agy --dangerously-skip-permissions"
QODER_CMD="qodercli"
SECRETS_PATTERNS=".env* local.settings.json .npmrc .pypirc"
AUTO_ATTACH="true"
PROMPT_INJECT_DELAY_MS=1500
```
