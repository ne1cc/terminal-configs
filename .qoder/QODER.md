# QODER.md — Global Qoder Agent Instructions

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

## Superpowers (Mandatory — Start of Every Session)

At the start of every conversation, read and follow the `using-superpowers` skill:
```
~/.qoder/skills/using-superpowers/SKILL.md
```
This skill establishes how to discover and invoke all relevant skills **before** any response, action, or clarifying question. New feature? Use brainstorming. Bug? Use systematic-debugging. Code review? There's a skill for that.

**This is non-negotiable.** Do not skip it. Do not assume you remember it. Read it fresh every session.

## Platform: Qoder

Read `~/.qoder/skills/using-superpowers/references/qoder-tools.md` for Qoder-specific tool mappings, if that file exists.

## Worktree & PR Lifecycle (mandatory)

All development happens in workmux-managed git worktrees (`.worktrees/`, one branch and one tmux window per worktree; manage with `wmux`). At the end of development:
1. Commit all work on the worktree's branch (Conventional Commits).
2. Push and open a PR: `git push -u origin <branch>`, then `gh pr create` with a title under 70 characters, a summary body, and a test plan.
3. Post a development retrospective as a PR comment: `gh pr comment <n> --body-file <file>`, using the template at `~/.qoder/templates/pr-retrospective.md` (problem → structure → what changed with why → verification → what it adds → honest ledger). Keep the draft in `/tmp`; post the comment URL alongside the PR URL. Skip for one-commit chore/fix PRs where the PR body already tells the whole story.
4. Report the PR URL (and retrospective comment URL). Done = PR URL reported.
5. After PR merge (or when the user requests merging): merge the PR, pull/fast-forward `main`, and clean up by running `wmr <branch>` (or `workmux remove <branch>`) and `git worktree prune`.

## Worktree Git Sync & Rebase Protocol

You are operating inside an isolated Git worktree. **Concurrent development is always happening on other branches.** Assume `main` has advanced since your worktree was created.

### At session start and before any commit
Check whether `origin/main` has new commits:
```bash
git fetch origin main && git log HEAD..origin/main --oneline
```
If output is non-empty, rebase immediately:
```bash
git rebase origin/main
```

### Conflict resolution rules
1. Never overwrite upstream changes blindly. Inspect both sides with `git diff`.
2. Preserve both features if logic permits; only remove code you authored if it is superseded.
3. After resolving each conflicted file: `git add <file>` then `git rebase --continue`.
4. `rerere` is enabled globally — repeat conflict patterns are replayed automatically.
5. Run the project test/typecheck suite after rebasing before resuming task work.

### Push safety
- Never `git push --force` to a shared branch.
- Use `git push --force-with-lease` only on your own feature branch after a rebase.
- Verify your delta: `git log --oneline origin/main..HEAD` before any push.

## Specification-Driven Execution & Checkpoint Protocol

To maintain high auditability, keep the human in the loop, and prevent rogue changes:

### 1. Scope Thresholds
- **Trivial changes** (single-file fixes, typos, dependency bumps, explicit direct instructions):
  - State the intention briefly in conversation.
  - Implement surgical changes directly and verify with tests.
- **Non-trivial changes** (≥2 files, architectural changes, schema/API changes, or ambiguous specs):
  - Follow the `spec-driven-execution` skill.
  - Strict two-phase lifecycle: Plan first, get explicit approval, then execute.

### 2. Phase 1 — Pre-Execution Plan & Review Gate
- Inspect the codebase and tests (read-only; **do NOT edit source files yet**).
- Write an implementation plan:
  - In Antigravity / UI runtimes: Save as an Antigravity Artifact (`write_to_file` with `ArtifactMetadata.RequestFeedback = true`, `ArtifactType: "plan"`).
  - In CLI / terminal runtimes: Write to `.scratch/<feature-name>/implementation_plan.md`.
  - Include: architecture/rationale, exact files to create/modify/delete, step-by-step TDD phases, and verification commands.
- **STOP and wait for user review/approval** before applying any file modifications.

### 3. Phase 2 — Surgical Execution & Audit Walkthrough
- Execute modifications matching the approved plan surgically.
- Run unit tests, linters, and verification commands.
- Capture the post-execution audit trail:
  - Save detailed verification notes and file diff summaries into `.scratch/<feature-name>/walkthrough.md` for immediate review.
  - Bridge into the PR Lifecycle: populate the PR description and post the Development Retrospective (`~/.qoder/templates/pr-retrospective.md`) so the audit persists permanently after worktrees are pruned.

# Markdown, Math & Diagram Formatting Rules

When generating or editing Markdown (`.md`) documents, notes, cheat sheets, or responses:

## 1. No Raw LaTeX Math Tags
- NEVER use raw LaTeX math delimiters or environments (`$$ ... $$`, `$...$`, `\text{...}`, `\frac{...}{...}`, `\le`, `\ge`, `\Delta`, `\sum`, `\rightarrow`).
- Many Markdown viewers (such as One Markdown, VS Code Markdown Preview, GitHub Markdown) do not enable LaTeX MathJax by default, causing raw tags to render as broken, unreadable code.

## 2. Monospace Calculation & Formula Blocks
- For all multi-step calculations, equations, summation proofs, and ratios, ALWAYS use clean fenced monospace code blocks:
  ```
  Total % Change = ∑ (Percentage Change_k)
                 = (Actual Change_1 / Allowable Change_1) + ...
                 = 50% + 75% = 125% > 100%
  ```

## 3. Native Unicode Typography
- Use standard native Unicode symbols for mathematical and logical expressions:
  - Inequality: `≤`, `≥`, `≠`, `≈`
  - Operations: `∑`, `×`, `÷`, `√N`, `±`
  - Greek / Derivatives: `Δ`, `μ`, `σ`, `λ`, `∈`
  - Arrows & Logic: `→`, `⇒`, `↔`, `⇔`

## 4. Currency vs. Math Collision Prevention
- Dollar signs (`$`) must NEVER be used as LaTeX math delimiters.
- When referencing currency, format values inside backtick code spans: `$10.00/hr`, `-$8.00`, `$5.00/yd`.

## 5. Inline Variables & Expressions
- Wrap variable names, parameters, and short inline formulas in backtick code spans: `x*`, `Δc_j`, `Q*`, `RiskTriang(100, 160, 220)`, `P* = 10/19 = 52.6%`.

## 6. Fenced Mermaid Diagrams
- Only use supported diagram types: `flowchart TD` / `flowchart LR` / `graph TD` / `graph LR`, `sequenceDiagram`, `stateDiagram-v2`, `classDiagram`, `erDiagram`.
- To prevent syntax errors:
  - Always quote node labels containing punctuation, parentheses, or brackets: `id["Label (Extra Info)"]`.
  - NEVER use reserved keywords (`end`, `graph`, `subgraph`, `flowchart`) as unquoted node IDs.

## 7. Fast File & Code Search (Use `rg` Instead of `find`)
- NEVER use traditional UNIX `find` or slow shell directory recursion when searching for files, archives, or code.
- ALWAYS use `rg` (Ripgrep) or `fd` for all file and directory discovery:
  - Finding files by pattern/name: `rg --files -g "*pattern*"` (or `fd "pattern"`)
  - Finding all files including hidden/ignored: `rg --files --hidden --no-ignore -g "*pattern*"` (or `fd -H -I "pattern"`)
  - Searching file contents: `rg "query"` or `rg -i "query"`
  - Listing matching file paths only: `rg -l "query"`
- Ripgrep respects `.gitignore` by default and uses multi-threaded traversal, preventing background command hangs and slow searches.

## 8. GitHub Namespace Layout & Shortcuts (mandatory)

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

### Rules agents must follow
1. Never invent a flat `~/Github/<repo>` path. Synced remotes live under `~/Github/ne1cc/<repo>`.
2. New work with no GitHub remote yet → `gnn` / `_local/projects/`, then `gnp` when ready to publish.
3. After `gnp`, the canonical path is `~/Github/ne1cc/<repo>`; do not leave promoted repos under `_local`.
4. Do not add third-party orgs to `.mirror-owners`. Use `gnc` for read-only clones; `gnf` to contribute.
5. Before promote/push: ensure `.gitignore` covers `.venv/`, `node_modules/`, `.env`, large data; never commit secrets.

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
   - State the **why** the code cannot show: race-condition guards, conditional write invariants, or status-code rationale.

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

## Clickable Absolute File Links (Mandatory Across All Outputs)

When referencing, creating, modifying, inspecting, or summarizing files, configs, scripts, or code symbols in any response, plan, walkthrough, or retrospective:

- **ALWAYS use GitHub-style Markdown links with the absolute `file://` URI scheme**:
  - Specific files: `[filename.ext](file:///absolute/path/to/filename.ext)`
  - Code symbols / line ranges: `[`symbolName`](file:///absolute/path/to/filename.ext#L10-L25)`
- **NEVER emit bare unlinked filenames or relative paths** (`./src/app.ts`, `app.ts`) when referencing files on disk. Every cited file must be a directly clickable link that opens immediately via click / shift-click in terminal emulators (Ghostty/tmux) and GUI interfaces.
- Always use forward slashes (`/`).

## Ponytail by default

For every coding task (writing, fixing, refactoring, reviewing, or choosing dependencies), read and follow `~/.qoder/skills/ponytail/SKILL.md` before starting work. Ponytail is active by default at full level. Honor explicit requests to change the level or disable Ponytail for the session.
