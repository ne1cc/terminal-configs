---
name: karpathy-guidelines
description: Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, reviewing, or refactoring code to avoid overcomplication, make surgical changes, surface assumptions, and define verifiable success criteria.
license: MIT
---

# Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls.

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

## 5. High-Signal Code Commenting & Walkthroughs

**No syntax restatement. High architectural signal. Document contracts, invariants, and the non-obvious why.**

When writing non-trivial code (multi-step routines, async workflows, security/auth, state machines, or branching logic):
1. **Boundary Docblock**:
   - 1-sentence intent.
   - Bulleted return & throw contract (`Returns <type> on success`, `Returns fallback on missing/stale`, `Throws/Rejects on ...`).
   - Known limits, helper assumptions, or `shortcut: <limit>, <when to upgrade>`.
2. **Numbered Step Comments (`// 1.`, `// 2.`, ...)**:
   - Group sequential blocks under numbered headings that fuse the action with the decision rule (`Condition → Action`).
   - State the **why** the code cannot show: race-condition guards (e.g. session swaps during pending `await`), conditional write invariants, or status-code rationale (`401` vs transient error).
3. **Walkthroughs in Responses (Chat, PRs, Docs)**:
   - Summarize code using: Executive Intent & Contract → Numbered Block-by-Block Breakdown (with monospace `Condition → Action` truth tables and async sequence traces) → Compact Unicode Flow Tree (`├─` / `└─`) → Important Limits & Failure Modes.

## 6. Clickable Absolute File Links

**No bare relative paths. Mandatory absolute `file://` links for all cited files and code symbols.**

When referencing, creating, modifying, inspecting, or summarizing files, configs, scripts, or code symbols in any response, plan, walkthrough, or retrospective:
- **ALWAYS use GitHub-style Markdown links with the absolute `file://` URI scheme**:
  - Specific files: `[filename.ext](file:///absolute/path/to/filename.ext)`
  - Code symbols / line ranges: `[`symbolName`](file:///absolute/path/to/filename.ext#L10-L25)`
- **NEVER emit bare unlinked filenames or relative paths** (`./src/app.ts`, `app.ts`) when referencing files on disk. Every cited file must be a directly clickable link that opens immediately via click / shift-click in terminal emulators (Ghostty/tmux) and GUI interfaces.
- Always use forward slashes (`/`).

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
