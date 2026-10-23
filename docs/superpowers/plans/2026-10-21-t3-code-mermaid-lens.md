# T3 Code Ephemeral Architecture Diagramming (`mermaid-lens`) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the `mermaid-lens` skill, global instruction hooks, T3 PR/Review Guide mapping, `Compile Diagrams` T3 toolbar Quick Action, and staged `.mmd` Git pre-commit validation across `terminal-configs` and live T3 Code settings.

**Architecture:** Add `.gemini/skills/mermaid-lens/SKILL.md` with token precedence overrides (`#diagram`, `--save-mmd`, `#no-diagram`), semantic complexity gating, and strict 12-node/double-quoted rendering invariants. Wire the skill into all 6 global instruction files, `bin/install-ponytail.sh`, `bin/link-agent-skills.sh`, and `~/.t3/userdata/settings.json`, plus add `bin/compile-mermaid.sh` and `bin/pre-commit-mermaid.sh` backed by `mmdc`.

**Tech Stack:** Bash, Python 3 (atomic JSON merger), Mermaid CLI (`mmdc` / `@mermaid-js/mermaid-cli`), Effect Schema / T3 Code `settings.json`, Git hooks.

**Spec:** [`docs/superpowers/specs/2026-10-21-t3-code-mermaid-lens-design.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/docs/superpowers/specs/2026-10-21-t3-code-mermaid-lens-design.md)

## Global Constraints

- Every global instruction file must remain strictly `< 18,000` bytes (under T3's `20,000`-byte `MAX_INSTRUCTION_FILE_CHARS` hard limit).
- Every file/symbol reference in outputs, plans, walkthroughs, and PRs must be a clickable `[name](file:///absolute/path)` link.
- Never use raw LaTeX math (`$$` or `$...$`); use monospace blocks and Unicode symbols.
- All Mermaid diagrams must use fenced `mermaid` blocks, alphanumeric node IDs, and double-quoted labels.

---

### Task 1: Create `mermaid-lens` Skill & Validation/Compilation Scripts

**Files:**
- Create: [`.gemini/skills/mermaid-lens/SKILL.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/.gemini/skills/mermaid-lens/SKILL.md)
- Create: [`bin/compile-mermaid.sh`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/bin/compile-mermaid.sh)
- Create: [`bin/pre-commit-mermaid.sh`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/bin/pre-commit-mermaid.sh)

- [ ] **Step 1: Create `.gemini/skills/mermaid-lens/SKILL.md` with override flags, silent semantic gate, diagram selection matrix, PR mapping rules, and syntax invariants**
- [ ] **Step 2: Create `bin/compile-mermaid.sh` to validate and compile `.mmd` files to `.svg` via `mmdc`**
- [ ] **Step 3: Create `bin/pre-commit-mermaid.sh` to validate staged `.mmd` files on `git commit`**
- [ ] **Step 4: Test `bin/compile-mermaid.sh` and `bin/pre-commit-mermaid.sh` against valid and invalid temporary `.mmd` inputs**
- [ ] **Step 5: Commit Task 1**

---

### Task 2: Wire `mermaid-lens` into All 6 Global Instruction Files

**Files:**
- Modify: [`AGENTS.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/AGENTS.md)
- Modify: [`.codex/AGENTS.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/.codex/AGENTS.md)
- Modify: [`.opencode/AGENTS.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/.opencode/AGENTS.md)
- Modify: [`claude-code/CLAUDE.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/claude-code/CLAUDE.md)
- Modify: [`.gemini/GEMINI.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/.gemini/GEMINI.md)
- Modify: [`.qoder/QODER.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/.qoder/QODER.md)

- [ ] **Step 1: Add `Post-Implementation & PR Visualization (mermaid-lens)` section to all 6 files with harness-specific skill paths**
- [ ] **Step 2: Verify all 6 files are strictly `< 18,000` bytes**
- [ ] **Step 3: Commit Task 2**

---

### Task 3: Update `bin/link-agent-skills.sh`, `bin/install-ponytail.sh`, and T3 `settings.json`

**Files:**
- Modify: [`bin/link-agent-skills.sh`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/bin/link-agent-skills.sh)
- Modify: [`bin/install-ponytail.sh`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-mermaid-lens/bin/install-ponytail.sh)
- Target: [`~/.t3/userdata/settings.json`](file:///Users/alex/.t3/userdata/settings.json)

- [ ] **Step 1: Update `bin/link-agent-skills.sh` to wire `.git/hooks/pre-commit`, add `compile-mermaid-diagrams` (`Compile Diagrams`) to T3 `defaultProjectScripts`, update `sourceControlWritingStyle` and `reviewGuideInstructions` with `mermaid-lens` PR mapping, and verify `mermaid-lens` in `--verify` mode**
- [ ] **Step 2: Include `mermaid-lens` in `bin/install-ponytail.sh` skill sync list**
- [ ] **Step 3: Run `bin/link-agent-skills.sh` and `bin/link-agent-skills.sh --verify`, and verify zero T3 schema errors in `~/.t3/userdata/logs/server.trace.ndjson`**
- [ ] **Step 4: Commit Task 3, push branch, open PR, and post retrospective comment**
