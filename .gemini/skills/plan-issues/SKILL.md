---
name: plan-issues
description: >
  File an agreed plan as a GitHub epic plus self-contained sub-issues that cheaper
  executor models can complete without asking questions. Use AFTER the user and a
  planner model have agreed on a list of improvements, when the user says "create the
  issues", "file these", "turn this plan into issues", or /plan-issues. It files; it
  does not decide what to build. Works in any ne1cc repo with no setup; after filing it hands the epic to ship-issues.
---

Turn the plan already agreed in this conversation into a GitHub epic and sub-issues. Do not invent work the user did not agree to. If the plan is still vague, say what is missing and stop.

An executor sees only its issue and the repo's `AGENTS.md`. Anything not written in the issue does not exist for it, and later comments on the issue are not seen. Write every issue accordingly.

## 1. Preconditions (miss → stop and say to run `gh auth login`)

- `gh auth status` works and you are inside the target repo.
- Nothing else is required. Repo templates, labels and `AGENTS.md` are optional.
- No `AGENTS.md`? Draft one from your review (Commands, Architecture in ≤5 lines, Conventions, Do not touch) and add it to the plan as an ordinary `exec:flash` sub-issue whose body holds the full text.

## 2. Draft

One epic and one issue per agreed item, using exactly the sections below (repo templates are not needed).

**Epic** (its body is the plan): Direction, Decisions (each with the reason and the rejected alternative), Plan (sub-issue list, filled in after filing), Out of scope.

**Each sub-issue**, every section filled:
- **Goal**: one sentence of what and why, `Part of #<epic>`.
- **Context**: exact file paths and what to change in each; an existing file or function to copy the pattern from; the decision or epic section that explains why.
- **Scope**: what is in, and an explicit "Out (do NOT touch)" list.
- **Acceptance criteria**: checkboxes that each name an input or state and an observable result. "Works correctly" is not a criterion.
- **Verify with**: exact copy-pasteable commands. Run each one once before filing: it must run, and may fail only where this issue's change is what fixes it (a new test). Never run a command that deploys, migrates, or writes outside the repo; write "(not pre-checked)" after those.
- **Dependencies**: `Blocked by #N` per blocker, or "None".

## 3. Quality gate

Do not file an issue that has an empty section, a vague criterion, no verify command, or a file path you did not confirm exists (check with `rg --files`; files the issue itself creates are exempt). Fix it, or go back to the user.

**Size is guidance, not a cap.** The target is one verifiable outcome with every file the executor must touch listed. Past about 5 files, or with unrelated criteria, suggest a split, but file it as written if the user says so. A wide mechanical change (rename, bulk migration) is fine as one issue when the check is objective.

**Tier label**:
- `exec:flash` (GLM 5.3 Flash, Gemini 3.8 Flash): there is a pattern to copy, scope is tight, and verification is objective.
- `exec:strong` (Sonnet 5.5, GPT Luna): design judgment needed, no pattern to copy, or a cross-layer change that is hard to fully specify.

## 4. Confirm, then file

Filing is outward-facing. Show the user all drafts as one list (order, title, tier, blockers, files) plus the epic body, and wait for approval. Say plainly that approval also starts the work: after filing, every unblocked issue is delegated at once. Apply any edits they ask for before filing.

File with bodies in temp files (use the session scratchpad, never the repo):

```bash
for l in epic exec:flash exec:strong shipped ship-failed ai-reviewed retro-posted; do gh label create "$l" --force >/dev/null; done
gh issue create --label epic --title "<epic title>" --body-file <epic.md>          # note the number E
gh issue create --parent E --label exec:<tier> --title "<title>" --body-file <issue.md>   # blockers first
gh issue edit E --body-file <epic-with-plan-list.md>                               # fill Plan: - [ ] #N title (tier)
```

File blockers before the issues that depend on them so every `Blocked by #N` points at a real number. Report the epic URL and each issue URL.

## 5. After filing

Use the `ship-issues` skill for the new epic in this same thread. It starts every unblocked issue in parallel, reviews each PR, starts blocked issues after their blockers merge, and posts the roll-up retrospective at the end. Tell the user: review and merge PRs as "Ready for you" messages arrive; switching this thread to Sonnet 5.5 now lowers the cost of completion wakes.
