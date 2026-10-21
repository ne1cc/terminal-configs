# T3 Code Quality Harnesses & Unified Provider Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify all T3 Code providers (`claude`, `codex`, `antigravity`, `opencode`), symlink topologies, T3's native quality engine, and on-demand cross-provider review under the Ponytail and High-Signal Code Commenting standard with zero T3 schema drift.

**Architecture:** Harmonize all 6 global instruction files in `terminal-configs` strictly under T3's 20 KB limit. Extend `link-agent-skills.sh` and `install-ponytail.sh` to maintain symlinks across all host and T3 provider paths (including all ACP provider instances), atomically merge strict Effect Schema-valid quality and toolbar settings into `~/.t3/userdata/settings.json`, and add on-demand `delegate_task` cross-model review to review skills.

**Tech Stack:** Shell (zsh/bash), Python 3 (atomic JSON manipulation with `tempfile`/`os.replace`), Effect Schema / JSON, Markdown, Git worktrees.

**Spec:** [`docs/superpowers/specs/2026-10-21-t3-code-quality-harnesses-design.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/docs/superpowers/specs/2026-10-21-t3-code-quality-harnesses-design.md)

## Global Constraints

- Every instruction file must be `< 18,000` bytes (T3's `MAX_INSTRUCTION_FILE_CHARS` is 20,000).
- Every file/symbol reference across all outputs must be a clickable absolute `file://` link.
- Never use raw LaTeX math (`$$` or `$...$`); use monospace calculation blocks and Unicode symbols.
- All diagrams must be fenced `mermaid` with quoted punctuation labels.
- `~/.t3/userdata/settings.json` must never be symlinked; use atomic JSON merger matching T3's Effect Schema types.
- Follow Conventional Commits and end every assistant response with a 1-2 line Ponytail footer.

---

### Task 1: Harmonize Instruction Files for All 6 Providers

**Files:**
- Modify: [`AGENTS.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/AGENTS.md)
- Modify: [`.codex/AGENTS.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/.codex/AGENTS.md)
- Modify: [`.opencode/AGENTS.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/.opencode/AGENTS.md)
- Modify: [`claude-code/CLAUDE.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/claude-code/CLAUDE.md)
- Modify: [`.gemini/GEMINI.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/.gemini/GEMINI.md)
- Modify: [`.qoder/QODER.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/.qoder/QODER.md)

**Interfaces:**
- Consumes: Canonical 11-rule matrix from design spec.
- Produces: 6 self-contained instruction files, each containing the 11 rules and sized `< 18,000` bytes.

- [ ] **Step 1: Inspect current sizes and sections of each instruction file**
- [ ] **Step 2: Update `AGENTS.md`, `.codex/AGENTS.md`, and `.opencode/AGENTS.md` with complete 11 sections**
- [ ] **Step 3: Update `claude-code/CLAUDE.md`, `.gemini/GEMINI.md`, and `.qoder/QODER.md` with complete 11 sections**
- [ ] **Step 4: Verify byte size of all 6 files is strictly `< 18,000` bytes**
- [ ] **Step 5: Commit changes**

```bash
git add AGENTS.md .codex/AGENTS.md .opencode/AGENTS.md claude-code/CLAUDE.md .gemini/GEMINI.md .qoder/QODER.md
git commit -m "feat(configs): harmonize 11-rule quality standards across all provider instruction files"
```

---

### Task 2: Extend Symlink Topology in Provisioning Scripts

**Files:**
- Modify: [`bin/link-agent-skills.sh`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/bin/link-agent-skills.sh)
- Modify: [`bin/install-ponytail.sh`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/bin/install-ponytail.sh)

**Interfaces:**
- Consumes: Target directory paths across `~`, `~/.t3`, `~/.claude`, `~/.codex`, `~/.config/opencode`, `~/.opencode`, `~/.gemini`, `~/.t3/userdata/providers/antigravity/*/`.
- Produces: Idempotent shell routines creating symlinks to repo assets with `--verify` flag support.

- [ ] **Step 1: Add symlink targets for `~/AGENTS.md`, `~/.t3/`, `~/.opencode/`, and all T3 Antigravity provider instances**
- [ ] **Step 2: Add `--verify` assertion mode to `bin/link-agent-skills.sh`**
- [ ] **Step 3: Update `bin/install-ponytail.sh` to mirror all targets**
- [ ] **Step 4: Test scripts locally on the worktree**
- [ ] **Step 5: Commit changes**

```bash
git add bin/link-agent-skills.sh bin/install-ponytail.sh
git commit -m "feat(scripts): extend symlink topology to all T3 Code provider paths with verify flag"
```

---

### Task 3: Implement Atomic Settings Merger for T3 Quality Engine

**Files:**
- Modify: [`bin/link-agent-skills.sh`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/bin/link-agent-skills.sh)
- Target: [`~/.t3/userdata/settings.json`](file:///Users/alex/.t3/userdata/settings.json)

**Interfaces:**
- Consumes: Existing JSON in `~/.t3/userdata/settings.json`.
- Produces: Preserved user keys + updated `reviewGuidesEnabled`, `reviewGuideInstructions`, `sourceControlWritingStyle`, `branchNamingMode: "semantic"`, `branchNameInstructions`, and `defaultProjectScripts`.

- [ ] **Step 1: Write embedded Python 3 atomic merger in `bin/link-agent-skills.sh` using `tempfile` and `os.replace`**
- [ ] **Step 2: Execute merger and verify zero schema errors in `~/.t3/userdata/logs/server.trace.ndjson`**
- [ ] **Step 3: Commit changes**

```bash
git add bin/link-agent-skills.sh
git commit -m "feat(t3): configure native quality engine and toolbar scripts in settings.json"
```

---

### Task 4: Enhance Review Skills for On-Demand Cross-Provider Review

**Files:**
- Modify: [`.gemini/skills/ponytail-review/SKILL.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/.gemini/skills/ponytail-review/SKILL.md)
- Modify: [`.gemini/skills/code-review/SKILL.md`](file:///Users/alex/Github/ne1cc/terminal-configs/.worktrees/feat-t3-code-quality-harnesses/.gemini/skills/code-review/SKILL.md)

**Interfaces:**
- Consumes: T3 Code native `delegate_task` MCP tool when present.
- Produces: Cross-model adversarial review dispatch strictly on-demand.

- [ ] **Step 1: Update `.gemini/skills/ponytail-review/SKILL.md` with on-demand `delegate_task` dispatch**
- [ ] **Step 2: Update `.gemini/skills/code-review/SKILL.md` with on-demand `delegate_task` dispatch**
- [ ] **Step 3: Commit changes**

```bash
git add .gemini/skills/ponytail-review/SKILL.md .gemini/skills/code-review/SKILL.md
git commit -m "feat(skills): add on-demand cross-provider review support via T3 delegate_task"
```

---

### Task 5: End-to-End Verification & PR Submission

**Files:**
- Worktree verification across all modified files and live symlinks.

- [ ] **Step 1: Run `bin/link-agent-skills.sh --verify` and assert 0 errors**
- [ ] **Step 2: Inspect `~/.t3/userdata/logs/server.trace.ndjson` to confirm T3 reloaded without parse errors**
- [ ] **Step 3: Check git log and git diff against origin/main**
- [ ] **Step 4: Push branch `feat/t3-code-quality-harnesses` to origin**
- [ ] **Step 5: Create Pull Request with `gh pr create`**
- [ ] **Step 6: Post Development Retrospective comment using `~/.qoder/templates/pr-retrospective.md`**
