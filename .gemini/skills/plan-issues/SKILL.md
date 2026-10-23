---
name: plan-issues
description: >
  File an agreed plan as a GitHub epic plus self-contained sub-issues that cheaper
  executor models can complete without asking questions. Use AFTER the user and a
  planner model have agreed on a list of improvements, when the user says "create the
  issues", "file these", "turn this plan into issues", or /plan-issues. It files; it
  does not decide what to build.
---

Turn the plan already agreed in this conversation into a GitHub epic and sub-issues. Do not invent work the user did not agree to. If the plan is still vague, say what is missing and stop.

An executor sees only its issue and the repo's `AGENTS.md`. Anything not written in the issue does not exist for it, and later comments on the issue are not seen. Write every issue accordingly.

## 1. Preconditions (any miss → stop and say what to run)

- `gh auth status` works and you are inside the target repo.
- `.github/ISSUE_TEMPLATE/agent-task.md` and `epic.md` exist, and the labels `epic`, `exec:flash`, `exec:strong` exist. Missing → tell the user to run `init-agent-kit` in this repo.
- `AGENTS.md` has real commands under "Commands" (not the empty skeleton). Missing → ask for them; never guess "Verify with" commands.

## 2. Draft

One epic and one issue per agreed item, following the repo's templates exactly.

**Epic** (its body is the plan): Direction, Decisions (each with the reason and the rejected alternative), Plan (sub-issue list, filled in after filing), Out of scope.

**Each sub-issue**, every section filled:
- **Goal**: one sentence of what and why, `Part of #<epic>`.
- **Context**: exact file paths and what to change in each; an existing file or function to copy the pattern from; the decision or epic section that explains why.
- **Scope**: what is in, and an explicit "Out (do NOT touch)" list.
- **Acceptance criteria**: checkboxes that each name an input or state and an observable result. "Works correctly" is not a criterion.
- **Verify with**: exact copy-pasteable commands, taken from `AGENTS.md` or an objective check (a grep that returns nothing, a test that must pass).
- **Dependencies**: `Blocked by #N` per blocker, or "None".

## 3. Quality gate

Do not file an issue that has an empty section, a vague criterion, no verify command, or a file path you did not confirm exists (check with `rg --files`). Fix it, or go back to the user.

**Size is guidance, not a cap.** The target is one verifiable outcome with every file the executor must touch listed. Past about 5 files, or with unrelated criteria, suggest a split, but file it as written if the user says so. A wide mechanical change (rename, bulk migration) is fine as one issue when the check is objective.

**Tier label**:
- `exec:flash` (GLM 5.3 Flash, Gemini 3.8 Flash): there is a pattern to copy, scope is tight, and verification is objective.
- `exec:strong` (Sonnet 5.5, GPT Luna): design judgment needed, no pattern to copy, or a cross-layer change that is hard to fully specify.

## 4. Confirm, then file

Filing is outward-facing. Show the user all drafts as one list (order, title, tier, blockers, files) plus the epic body, and wait for approval. Apply any edits they ask for before filing.

File with bodies in temp files (use the session scratchpad, never the repo):

```bash
gh issue create --label epic --title "<epic title>" --body-file <epic.md>          # note the number E
gh issue create --parent E --label exec:<tier> --title "<title>" --body-file <issue.md>   # blockers first
gh issue edit E --body-file <epic-with-plan-list.md>                               # fill Plan: - [ ] #N title (tier)
```

File blockers before the issues that depend on them so every `Blocked by #N` points at a real number. Report the epic URL and each issue URL.

## 5. After filing

Remind the user: hand each issue to an executor in its own worktree (the issue is the approved spec); when the last sub-issue closes, post one retrospective comment on the epic (what landed, what was kicked back, what the split taught you about each model).
