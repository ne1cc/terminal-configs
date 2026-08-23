---
name: handoff
description: Generate and record an enterprise-grade Antigravity session handoff snapshot (capturing git branch, diffs, commits, runtime toolchains, open ports, tmux session state, and open next steps roadmap) into .gemini/sessions/ and ~/.gemini/sessions/. Trigger on "handoff", "/handoff", "wrap up", "save session state", "end of session", or "create a handoff".
---

# Enterprise Antigravity Session Handoff Skill

When invoked (via `/handoff`, "handoff", "wrap up session", or "save session state"):

## Execution Workflow

1. **Synthesize Session Context & Accomplishments**:
   - Extract the primary task completed or in progress during this conversation.
   - Formulate clear, actionable next steps for the next session.

2. **Execute the Robust Handoff Generator**:
   - Run the local helper script with the derived topic name and summary notes:
     ```bash
     $HOME/bin/session-handoff "<topic-name>" "<optional-summary-notes>"
     ```
   - This automatically writes to:
     - `.gemini/sessions/YYYY-MM-DD-<topic>.md` (and maintains `.gemini/sessions/latest.md` symlink)
     - `~/.gemini/sessions/YYYY-MM-DD-<topic>.md` (and maintains `~/.gemini/sessions/latest.md` symlink)
     - `.claude/memory/sessions/` (mirrored for interoperability)

3. **Verify State Captured**:
   - Verify that:
     - Working tree status, staged/unstaged diff stats, and recent commits are accurate.
     - Runtime toolchains and listening ports are cataloged.
     - Multiplexer state and open panes are recorded.
     - Fast resumption prompt is rendered.

4. **Deliver Terse Confirmation**:
   - Provide the user with:
     - The saved handoff path (`.gemini/sessions/latest.md`).
     - A 1-sentence prompt for their next session: `Resume from .gemini/sessions/latest.md`.
