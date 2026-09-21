---
name: spec-driven-execution
description: Use when executing non-trivial, multi-file, or architectural modifications requiring an upfront implementation plan in a scratch directory or artifact, human review gate before code mutations, and a post-execution verification walkthrough.
---

# Specification-Driven Execution

Strict two-phase lifecycle for non-trivial, architectural, or multi-file changes: plan first, pause for human approval, surgically execute, and audit.

## When to Use This Skill
- Any task modifying 2 or more production files.
- Architectural refactors, schema migrations, public API changes, or new feature additions.
- Any task where the approach has multiple interpretations or non-obvious trade-offs.

*Note: For trivial tasks (single-line fixes, simple typos, dependency bumps, direct diagnostic queries), skip this heavy ceremony and execute surgically with tests.*

---

## The Workflow

```
[User Task]
     │
     ▼
Phase 1: Pre-Execution Plan & Review Gate (READ-ONLY)
  - Inspect codebase, tests, dependencies
  - Write plan:
      * Antigravity / UI: Native Artifact (RequestFeedback: true)
      * CLI / Terminal agents: .scratch/<task-name>/implementation_plan.md
  - STOP: Await user approval before touching code!
     │
     ▼ (User Approves / "Proceed")
Phase 2: Surgical Implementation
  - Follow approved plan strictly
  - TDD cycle (Red -> Green -> Refactor)
  - Run linters, typechecks, and tests
     │
     ▼
Phase 3: Post-Execution Audit & Permanent Record
  - Write verification details into .scratch/<task-name>/walkthrough.md
  - Record permanent audit:
      * PR Description & PR Retrospective (~/.qoder/templates/pr-retrospective.md)
```

---

## Phase 1: Pre-Execution Planning & Review Gate

1. **Read-Only Inspection**:
   - Inspect existing architecture, relevant files, test suites, and configs.
   - Do **NOT** edit, create, or delete any source code files yet.

2. **Generate the Implementation Plan**:
   - For GUI/Artifact environments (e.g. Antigravity IDE / Antigravity 2.0):
     Create a native Artifact with `ArtifactMetadata`:
     `RequestFeedback: true`, `UserFacing: true`, and `ArtifactType: "plan"`.
   - For terminal/CLI environments (e.g. agy CLI, Claude Code, Codex, OpenCode):
     Create `.scratch/<task-name>/implementation_plan.md` (or `.scratch/implementation_plan.md` if single task).
   - Plan contents:
     * **Context & Objective**: What problem this solves and the technical approach.
     * **Files to Touch**: Exact paths to create, modify, or delete.
     * **Phases & Steps**: Bite-sized, sequential tasks with clear boundaries.
     * **Verification Plan**: Exact commands to run (unit tests, linters, builds).

3. **Enforce the Human-in-the-Loop Review Gate**:
   - **STOP completely**. Do not invoke write tools on production files.
   - Present the plan to the user and request confirmation.
   - If in Antigravity, let the user click the "Proceed" button on the artifact.
   - If in CLI, output the plan summary and prompt the user: *"Please review the plan above. Shall I proceed with implementation?"*

---

## Phase 2: Surgical Implementation

Once the user approves:
1. **Execute Task by Task**:
   - Touch only what was approved in the plan.
   - Match existing project coding standards and patterns.
   - Do not refactor unrelated code or add unrequested speculative features.
2. **Verify Every Step**:
   - Run unit tests, typechecks, and linters after each meaningful edit.
   - Ensure clean diffs.

---

## Phase 3: Post-Execution Audit & Permanent Record

1. **Local Walkthrough**:
   - Create `.scratch/<task-name>/walkthrough.md` detailing:
     * List of all modified, created, or deleted files.
     * Summary of what changed per file and why.
     * Raw or summarized test verification output.
2. **Permanent Audit Bridge**:
   - Remember: `.scratch/` is gitignored and will be removed when worktrees are pruned (`wmr`).
   - For worktree / PR workflows:
     * Feed the walkthrough findings directly into the Pull Request description.
     * Post the Development Retrospective comment using `~/.qoder/templates/pr-retrospective.md`.
     * Report the PR URL and retrospective URL to the user.
