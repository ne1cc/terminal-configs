---
name: delegate-agy
description: Delegate tasks and executions directly to Antigravity CLI (agy) from Claude Code prompts or slash commands like /agy-setup and /agy.
---

# Delegate to Antigravity CLI (`agy`)

This skill allows Claude Code to bridge and delegate tasks to the Antigravity CLI (`agy`).

## Capabilities & Workflows

1. **Setup & Initialization (`/agy-setup`)**
   - Verifies that `antigravity` / `agy` is installed and accessible in the system `$PATH`.
   - Ensures login credentials and local workspace configurations are valid.

2. **Delegate Executions (`/agy <prompt>`)**
   - Runs `antigravity` with the specified prompt or audit wrapper (`antigravity_audit` / `agya`).
   - Streams output back into the workspace session.

