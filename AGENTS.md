# Global Agent Instructions

## Worktree & PR Lifecycle (mandatory)

All development happens in workmux-managed git worktrees (`.worktrees/`, one branch and one tmux window per worktree; manage with `wmux`). At the end of development, before the user removes the worktree (`wmr`) and prunes:
1. Commit all work on the worktree's branch (Conventional Commits).
2. Push and open a PR: `git push -u origin <branch>`, then `gh pr create` with a title under 70 characters, a summary body, and a test plan.
3. Post a development retrospective as a PR comment: `gh pr comment <n> --body-file <file>`, using the template at `~/.qoder/templates/pr-retrospective.md` (problem → structure → what changed with why → verification → what it adds → honest ledger). Keep the draft in `/tmp`; post the comment URL alongside the PR URL. Skip for one-commit chore/fix PRs where the PR body already tells the whole story.
4. Report the PR URL (and retrospective comment URL). Done = PR URL reported. The user merges the PR, then runs `wmr` and `git worktree prune` themselves.

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

## Ponytail by default

For every coding task (writing, fixing, refactoring, reviewing, or choosing dependencies), read and follow `~/.agents/skills/ponytail/SKILL.md` before starting work. Ponytail is active by default at full level. Honor explicit requests to change the level or disable Ponytail for the session.
