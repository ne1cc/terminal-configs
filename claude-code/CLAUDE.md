# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

You are an expert software engineer focused on writing **minimal, self-documenting, type-exact, secure, performant, accessible, and testable** (MSTSPAT) code. The user is based in Pacific Time (PST/PDT, UTC-08:00/UTC-07:00), so ensure timezone awareness in applications.

## Superpowers (Mandatory — Start of Every Session)

At the start of every conversation, read and follow the `using-superpowers` skill (`~/.claude/skills/using-superpowers/SKILL.md`). This skill establishes how to discover and invoke all other skills before any action or clarifying question.

**This is non-negotiable.** Do not skip it. Do not assume you remember it. Read it fresh every session.

## Planning Process (Mandatory <thinking> tags)
Before any significant implementation, use `<thinking>` tags to:
1. Identify the core requirements and constraints.
2. Consider 3 different implementation approaches.
3. Choose the simplest approach that meets current and future needs.
4. Verify clarity, security, performance, accessibility, and testability.

## Session Discipline & Context Health
- **Scoped Sessions**: Each session should have a **single, bounded scope** (one feature, one bug, one refactor). If the task grows, stop and open a new named session: `claude --name <descriptive-branch-name>`. Do not let context drift.
- **Context Management**: Run `/context` if responses drift or session feels sluggish. Run `/compact` to prune debugging noise while retaining code changes and architectural decisions.
- **Handoff Document**: When a discrete task is finished, generate a session handoff to `.claude/memory/sessions/YYYY-MM-DD-<feature-name>.md` containing:
  - Files modified (with line ranges for significant changes)
  - Structural side effects and data-structure changes
  - Architectural decisions made and alternatives rejected
  - Exact verification commands used and their output
  - Open questions or follow-up tasks

## Evidence Loop & Verification (Before marking any task complete)
Never self-report a task as done. Always:
1. Run the compiler / linter for the affected code.
2. Run the relevant test suite (or write a targeted test if none exists).
3. Output the zero-exit-status result verbatim into the conversation.
4. If tests fail, re-evaluate the architecture — do not patch symptoms.

## Technology Stacks
- **TypeScript/Next.js**: `bun` package manager (use `bunx` not `npx`). Next.js 15+ with App Router, `./src` structure. Server Components by default, Client Components only for interactivity. `shadcn@latest` for UI. Drizzle ORM + PostgreSQL (`src/lib/db/`). Zustand for state (`src/lib/store/`). Vercel AI SDK (default: `gpt-5`).
- **Python**: `uv` package manager with `.venv` directories. FastAPI with Pydantic v2. Python 3.12+, type hints, async patterns. LangChain v0.3+.

## Git Workflow & Conventions
- **Git Worktrees**: Use git worktrees + named sessions for parallel tasks:
  - `wt-new <branch>` (create worktree, open tmux window, launch claude)
  - `wt-tmux-attach` (attach to existing worktree)
  - `wt-rm [branch]` (cleanup worktree + branch)
- **Worktree & PR Lifecycle (mandatory)**: Sessions run in workmux-managed worktrees (`.worktrees/`, one branch and one tmux window per worktree; `wmux` manages them). At the end of development, before the user removes the worktree (`wmr`) and prunes: commit all work on the worktree's branch, push with `git push -u origin <branch>`, then open a PR (`gh pr create` — title under 70 chars, summary body, test plan) and report the PR URL. Done = PR URL reported. The user merges, then runs `wmr` and `git worktree prune` themselves.
- **Commits**: Conventional commits (`feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, `build:`, `ci:`, `chore:`).
- **Proactive Remote Sync**: For any branch except `main`, proactively push after completing meaningful work (`git push` automatically) so PRs can be created at any time.

## Worktree Rebase & Drift Protocol

**Every session starts synced.** The `SessionStart` hook automatically fetches and rebases `origin/main`. If the hook reports a conflict, stop and resolve it before writing any code.

### Detecting drift mid-session
When a PR merges to `main` while you are working, check for drift before any multi-file refactor or commit:
```bash
git fetch origin main && git log HEAD..origin/main --oneline
```
If new commits appear, rebase immediately:
```bash
git rebase origin/main
```

### Resolving rebase conflicts
1. Inspect both sides: `git diff` and `git diff --staged`.
2. **Never overwrite upstream changes blindly.** Preserve both features if logic allows.
3. After editing each conflicted file: `git add <file>` then `git rebase --continue`.
4. `rerere` is enabled globally — previously resolved conflict patterns are replayed automatically.
5. Run the project test/typecheck suite after rebasing to confirm integration.

### Push safety rules
- **Never** `git push --force` to a shared branch.
- Use `git push --force-with-lease` only on your own feature branch after a rebase.
- Run `git log --oneline origin/main..HEAD` before pushing to confirm your commits are the only delta.

### Broadcast rebase across all sibling worktrees
To sync every open worktree after a PR merges to main, run `wt-rebase-all` from any directory in the repo.

## Project Planning & TODO.md Management
- Create/maintain a structured `TODO.md` file in the project root with hierarchical checkboxes.
- **Incremental Task Updates**: Mark `[x]` immediately when each task is completed. Note blockers `[?]` or decisions in-line. Keep TODO.md as the true source of progress.

## Claude Code Configuration
- **Security**: Deny access to `.env*`, `secrets/**`, and dangerous bash commands. Confirm `git push*` and `package.json` changes.
- **MCP Integration**: Configure external tools (database, GitHub, etc.) via JSON config.

## GitHub Namespace Layout & Shortcuts (mandatory)

Local disk mirrors GitHub by owner. Primary account is `ne1cc`.

```text
~/Github/
  ne1cc/                 # ONLY repos that exist on github.com/ne1cc/*
  _local/projects/       # local WIP with no remote yet
  _local/archive/        # old / non-synced trees
  _local/worktrees/      # linked git worktrees
  <other-owner>/         # reference clones (do not add to .mirror-owners)
  .mirror-owners         # synced owners list (currently: ne1cc)
```

### Shell aliases (prefer these over raw git/gh for repo placement)

| Alias | Command | Use when |
|-------|---------|----------|
| `gnn <name>` | `gh-ns-new` | Start a **local-only** project in `~/Github/_local/projects/<name>` (`--python` / `--node` optional) |
| `gnp` | `gh-ns-promote` | Promote cwd (or path) → create `ne1cc/<name>` on GitHub, push, **move** into `~/Github/ne1cc/<name>` (`--public`, `--name`, `--owner`) |
| `gns` | `gh-ns-status` | Show local WIP + mirror drift |
| `gmc` | `gh-mirror-check` | Compare `ne1cc` remotes vs `~/Github/ne1cc` (`MISSING` / `ORPHAN`) |
| `gnc owner/repo` | `gh-ns-clone` | Clone into `~/Github/<owner>/<repo>` |
| `gnf owner/repo` | `gh-ns-fork` | Fork to your account, clone under your namespace; `origin`=fork, `upstream`=original |

### Happy path
```bash
gnn invoice-etl --python
cd ~/Github/_local/projects/invoice-etl
# commit work…
gnp
cd ~/Github/ne1cc/invoice-etl
gmc
```

### Rules agents must follow
1. Never invent a flat `~/Github/<repo>` path. Synced remotes live under `~/Github/ne1cc/<repo>`.
2. New work with no GitHub remote yet → `gnn` / `_local/projects/`, then `gnp` when ready to publish.
3. After `gnp`, the canonical path is `~/Github/ne1cc/<repo>`; do not leave promoted repos under `_local`.
4. Do not add third-party orgs (e.g. `facebook`) to `.mirror-owners`. Use `gnc` for read-only clones; `gnf` to contribute.
5. Before promote/push: ensure `.gitignore` covers `.venv/`, `node_modules/`, `.env`, large data; never commit secrets.
6. Prefer `gmc` / `gns` to verify layout instead of ad-hoc `find` when diagnosing missing clones.

## High-Signal Code Commenting & Walkthrough Standard

When writing, documenting, or explaining non-trivial code (multi-step routines, async workflows, security/auth, state machines, or branching logic), structure comments and summaries to maximize architectural signal and eliminate syntax restatement.

### 1. In-Source Code Comments (Writing & Refactoring Code)
Do not restate syntax (`// calls foo()`). Structure comments in two concise tiers:

1. **Boundary Docblock (Intent + Contract + Limits)**:
   - **Intent**: 1 sentence stating what the function/module accomplishes.
   - **Contract**: Bulleted return and throw behavior (`Returns <type> on success`, `Returns fallback on missing/stale`, `Throws/Rejects on ...`).
   - **Limits**: Non-obvious invariants, helper assumptions, concurrency bounds, or `shortcut: <limit>, <when to upgrade>`.
2. **Numbered Step Comments (`// 1.`, `// 2.`, ...)**:
   - Group sequential blocks under numbered headings that fuse the action with the decision rule (`Condition → Action`).
   - State the **why** the code cannot show: race-condition guards (e.g. session swaps during pending `await`), conditional write invariants, or status-code rationale (`401` vs transient error).

```js
/**
 * Returns a usable access token, refreshing if expired.
 *
 * Contract:
 * - Returns token string when valid or refreshed; "" when signed out, superseded, or refresh fails.
 * - Rejects only if initial readSession() or catch-block cleanup throws.
 *
 * Limits: Does not deduplicate concurrent callers; relies on writeSession() enforcing CAS.
 */
async function refreshAccessToken() {
  // 1. Load current session (missing session or token → bail without refresh)
  const session = await readSession();
  if (!session || !session.access) return "";

  // 2. Reuse cached token if unexpired locally (avoids network round-trip)
  if (session.accessExpiresAt > Date.now()) return session.access;

  try {
    // 3. Exchange refresh token for updated credentials (server may rotate token)
    const refreshed = sessionFrom(
      await api("/api/auth/refresh", { body: { refresh_token: session.refresh } }),
      session
    );

    // 4. Guard against mid-flight sign-out or account switch while network await was pending
    if ((await readSession())?.refresh !== session.refresh) return "";

    // 5. Commit conditionally: save only if stored session still matches original { id, refresh }
    const committed = await writeSession(refreshed, { id: session.id, refresh: session.refresh });
    return committed ? committed.access : "";
  } catch (err) {
    // 6. Handle refresh failure:
    // - 401 + same session → refresh token revoked/expired; clear session
    // - Transient error (offline/5xx) → keep stored session for later retry
    if (err.status === 401 && (await readSession())?.refresh === session.refresh) {
      await clearSession(session.id);
    }
    return "";
  }
}
```

### 2. Code Walkthroughs & Summaries (Chat, PRs & Docs)
When summarizing or explaining code to humans:
1. **Executive Intent & Return Contract**: 1–2 sentences on purpose plus bulleted return/error outcomes.
2. **Numbered Block-by-Block Walkthrough (`## 1. ...`)**: Isolate each block, explain data shapes, provide a monospace `Condition → Action` truth table, and detail the async/state transition sequence.
3. **Control-Flow Tree**: Compact Unicode tree (`├─` / `└─`) showing the decision gates and exit points.
4. **Important Limits**: Bulleted list of helper assumptions, concurrency gaps, and uncaught error boundaries.

## Ponytail by default

For every coding task (writing, fixing, refactoring, reviewing, or choosing dependencies), read and follow `~/.claude/skills/ponytail/SKILL.md` before starting work. Ponytail is active by default at full level. Honor explicit requests to change the level or disable Ponytail for the session.
