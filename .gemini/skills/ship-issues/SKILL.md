---
name: ship-issues
description: >
  Orchestrate a filed epic through T3 delegated tasks: start every unblocked sub-issue
  in its own worktree on the model its exec:* label names, review each PR with a Sonnet
  reviewer (up to two fix rounds), start newly unblocked issues after merges, and post the
  roll-up retrospective when all sub-issues close. Use after plan-issues files an epic,
  when a scheduled wake says "Use the ship-issues skill for epic #E", when a delegated
  child finishes, or on /ship-issues owner/repo#E. Safe to run any number of times.
---

One pass over epic #E in owner/repo. GitHub is the only state: read it fresh every pass and act only on what changed. Never merge, never close a sub-issue yourself, never delegate the same thing twice.

## Tools

T3 tools may carry a prefix such as `mcp__t3_code__`. Use `delegate_task` (not native subagents) for every child: `isolation: "worktree"`, `mode: "async"`, a `clientRequestId` of the form `<repo>-<E>-<kind>-<N>-<round>` (stable across retries). Resolve `providerInstanceId` and `model` for **GLM 5.3 Flash** and **Sonnet 5.5** from `orchestrator_capabilities` each pass.

| Label | Model |
| :--- | :--- |
| `exec:flash` | GLM 5.3 Flash |
| `exec:strong` | Sonnet 5.5 |
| reviewer (any issue) | Sonnet 5.5 |
| fixer | same as the issue's label |

## 1. Read state

```bash
gh issue view E -R owner/repo --json state,labels
gh api repos/owner/repo/issues/E/sub_issues --paginate --jq '.[] | {number,state,title,labels:[.labels[].name],body}'
gh pr list -R owner/repo --state all --json number,state,headRefOid,labels,body,url --limit 200
```

A sub-issue's PR is the one whose body contains `Closes #N`. Epic closed → disable this thread's schedule for E and stop.

## 2. Schedule

If this thread has no enabled scheduled task for E, call `schedule_task` bound to this thread: every 15 minutes, model GLM 5.3 Flash, prompt `Use the ship-issues skill for epic #E in owner/repo.` Keep its id in your reply so later passes can disable it.

## 3. Start unblocked issues

For each **open** sub-issue without `shipped` or `ship-failed`:
- Any `Blocked by #M` where #M is not closed → skip it (it waits).
- No `exec:*` label → add `ship-failed`, say so.
- Otherwise add `shipped`, then `delegate_task` with the issue's model and this task text:

```text
<full issue body>

Implement GitHub issue #N in owner/repo following the Issue-Driven Work section of your instructions:
one branch, PR body starts "Closes #N", fill every PR template section, post the retrospective comment,
call link_pull_request. Fetch origin main and rebase before you start. Return the PR URL, retro comment
URL and head SHA. Do not watch or poll the PR.
```

If `delegate_task` errors, swap `shipped` for `ship-failed` and say so. Start every ready issue in this pass (parallel).

## 4. Review PRs

For each **open** PR of a sub-issue without `ai-reviewed`: count its comments starting `AI review round`. If 2 or more, skip (it is yours). Otherwise add `ai-reviewed` to the PR, call `link_pull_request` for it, and delegate the Sonnet reviewer:

```text
Review PR <url> against GitHub issue #N in owner/repo (body below). Read `gh pr diff <P>` and the PR body.
Post exactly one PR comment that starts "AI review round <k>: APPROVE" or "AI review round <k>: CHANGES",
then numbered findings, each tied to an acceptance criterion or a correctness risk. Do not change code.
Return the verdict line.

<full issue body>
```

## 5. Act on finished reviews

When a reviewer returns (T3 wakes you, or `task_status` shows it done):
- **APPROVE**, or **CHANGES** in round 2 → post `Ready for you: PR #P (<verdict>)` in this thread.
- **CHANGES** in round 1 → delegate a fixer on the issue's model:

```text
PR <url> for GitHub issue #N in owner/repo has review findings. Run `gh pr checkout <P>`, read every
comment starting "AI review round", address each finding or reply on the PR why not, rerun the issue's
"Verify with" commands, and push to the same branch. Append what you changed to the PR retrospective
comment. Return the new head SHA.

<full issue body>
```

When the fixer returns, remove `ai-reviewed` from the PR so step 4 reviews the new head.

## 6. Finish the epic

All sub-issues closed and the epic lacks `retro-posted`: post one roll-up retrospective comment on E (template `~/.qoder/templates/pr-retrospective.md`): each sub-issue with its PR and retrospective link, what review rounds caught, what each model did well or badly. Then add `retro-posted`, close E, and disable this thread's schedule for E.

## 7. Report

Something changed → one short message: started, waiting (with blockers), in review, ready for you, failed. Nothing changed → end the turn without a message.
