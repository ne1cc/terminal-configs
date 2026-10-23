---
name: mermaid-lens
description: >
  Post-implementation and PR architectural visualizer. Evaluates semantic code
  changes, codebase comprehension queries, and Pull Request diffs to render an
  inline Mermaid diagram in T3 Code when control flow, state machines, data
  pipelines, or system boundaries are mutated. Also triggers immediately when
  the user includes override tokens: #diagram, --save-mmd, or #no-diagram.
---

# Mermaid Lens (Conditional Architecture & PR Visualizer)

You evaluate completed code implementations, Pull Request diffs, or architectural comprehension queries and render a high-signal Mermaid diagram.

## 0. Explicit User Override Flags (Highest Priority — Evaluate Before Gate)
Scan the user's prompt for these exact tokens before running the semantic gate:

1. **`#no-diagram`**:
   - **Action**: Hard abort. Do not generate a diagram and do not mention skipping it, even if massive architectural changes occurred.
2. **`#diagram`**:
   - **Action**: Bypass the Silent Gate (`Section 1`). Force-generate an inline ` ```mermaid ` diagram in the chat response (or PR/Review Guide) for the target code, module, or diff, even if the change is small or localized. Do NOT write any `.mmd` files to disk.
3. **`--save-mmd` or `--save-mmd=<custom/path.mmd>`**:
   - **Action**: Bypass the Silent Gate (`Section 1`). Force-generate the diagram inline in the chat response AND write the diagram to disk:
     - Default path (if no `=<path>` specified): `docs/diagrams/<kebab-case-feature-or-module>.mmd` (create parent directories if missing; write raw Mermaid syntax without markdown fences).
     - Custom path (if `=<path>` provided): Write to the exact path specified. If the target ends in `.md`, append or update a fenced ` ```mermaid ` block inside that Markdown file; if `.mmd`, write raw Mermaid syntax without fences.
     - Append a 1-line confirmation below the inline diagram: `Saved diagram to [<filename>](file:///absolute/path/to/file)`.

*If none of the above tokens are present in the user prompt, proceed to Section 1 (The Silent Gate).*

## 1. The Silent Gate (Default Mode)
Inspect the semantic nature of the changes just implemented (or the PR branch diff `origin/main...HEAD` when mapping a PR or T3 Review Guide).

**ABORT SILENTLY (output zero text about skipping diagrams) if ANY of the following are true:**
- **Boilerplate / Isomorphic Change**: Adds a CRUD route, UI component, or test file mirroring an existing pattern without new branching logic.
- **Mechanical Refactor**: Mass file renames, import sorting, type annotations, linter fixes, CSS/Tailwind tweaks, or config updates (even if 10+ files were touched).
- **Bug Fix / Iteration Loop**: Fixing a compiler error, failing test, or minor edge case from a previous turn.
- **Trivial Linearity**: Execution path is obvious in under 10 seconds by reading the raw diff.

**PROCEED ONLY IF the change introduces or mutates at least one of:**
1. **Cross-Boundary I/O**: New interactions between client, API, worker, cache, external service, or DB.
2. **State Machines**: Non-linear state transitions, lifecycle hooks, or concurrency locks.
3. **Complex Control Flow / DAGs**: Multi-branch pipeline orchestration, fallback/retry chains, or pub/sub event routing.
4. **Schema / Entity Topology**: 3+ interconnected relational tables or domain models.

## 2. Diagram Selection Matrix
Pick the single highest-signal diagram type for the mutation:
- `sequenceDiagram`: Async handshakes, RPC/API call chains, auth flows, worker queues (use actor lifelines and `activate`/`deactivate` blocks where helpful for call tracing).
- `stateDiagram-v2`: Entity lifecycles, UI/store state machines, connection states.
- `flowchart LR` (or `TD`): Data pipelines, DAGs, multi-branch decision trees, system trust boundaries (`Client`, `Gateway`, `Core Engine`, `Database`).
- `erDiagram`: Database schema migrations involving multiple foreign-key relationships.

## 3. Strict Rendering & Syntax Invariants
To prevent Mermaid parser crashes and unreadable layouts inside the T3 Code chat pane and PR views:
- **Inline Ephemeral Default**: Render the ` ```mermaid ` fenced block directly in the chat response (and inside PR descriptions / T3 Review Guides when mapping PRs). Never write `.mmd` files to disk unless `--save-mmd` was passed.
- **Hard Complexity Cap**: Maximum **12 nodes** and **3 subgraphs/actors**. Abstract helper functions into boundary nodes.
- **Mandatory Quoting & Safe IDs**:
  - Every node label MUST be wrapped in double quotes using simple alphanumeric IDs (e.g., `AuthSvc["Auth Service (JWT)"]`).
  - Never place unescaped `()`, `[]`, `{}`, `;`, or generics `<T>` in raw node definitions, and never include HTML tags.
  - Never use reserved Mermaid keywords (`end`, `graph`, `subgraph`, `flowchart`) as unquoted node IDs.
- **Delta Highlighting (Implementation & PR Mapping)**: Prefix newly added or mutated components in labels (e.g., `BatchWorker["[NEW] Batch Worker"]` or `TokenRefresh["[MODIFIED] Token Refresh"]`).
- **Zero Fluff**: Place a single 1-sentence caption above the diagram stating the exact mental model or PR delta it represents.
