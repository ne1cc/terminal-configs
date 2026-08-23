---
name: research-to-ui-planner
description: Structured pipeline to brainstorm requirements, generate architectural specs, and produce production-ready frontend designs.
argument-hint: [project-name-or-concept]
---

# Research-To-UI Planner

End-to-end execution pipeline connecting problem exploration, architectural specification, and UI component production.

## Operational Workflow

When starting a new feature or project, execute across 3 strict sequential phases:

### Phase 1: Ideation & Socratic Probing
- Invoke `socratic-ideator` heuristics (Abstraction Ladder, Tension Hunting).
- Clarify user persona, constraints, and operational bottlenecks.
- Run Failure Analysis: Identify the top 3 ways this could fail before writing code.

### Phase 2: System Specification & Architecture
- Invoke `writing-plans` and `mermaid-architect`.
- Define data schemas, state machines, and API boundary contracts in TypeScript / Dart interfaces.
- Construct the component hierarchy and dependency graph.
- Establish atomic checkpoints with explicit verification steps.

### Phase 3: UI/UX Production & Verification
- Invoke `frontend-design` and `web-artifacts-builder`.
- Apply explicit design tokens, typography scales, and responsive layout constraints.
- Implement all core states: Empty, Loading, Error, Optimistic UI, and Success.
- Validate interactions using `playwright-expert` or `webapp-testing`.
