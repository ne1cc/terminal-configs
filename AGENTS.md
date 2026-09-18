# Global Agent Instructions

## Worktree & PR Lifecycle (mandatory)

All development happens in workmux-managed git worktrees (`.worktrees/`, one branch and one tmux window per worktree; manage with `wmux`). At the end of development, before the user removes the worktree (`wmr`) and prunes:
1. Commit all work on the worktree's branch (Conventional Commits).
2. Push and open a PR: `git push -u origin <branch>`, then `gh pr create` with a title under 70 characters, a summary body, and a test plan.
3. Report the PR URL. Done = PR URL reported. The user merges the PR, then runs `wmr` and `git worktree prune` themselves.

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
