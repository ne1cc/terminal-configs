---
name: pr-reviewer
description: Conduct thorough, adversarial code reviews on pull requests, git diffs, or pending changes. Activates when asked to "review this PR", "review diff", "audit changes", or "check for regressions".
---

# PR Reviewer & Adversarial Audit

## Review Checklist
- **Correctness & Logic Bugs**: Off-by-one errors, state invalidation, race conditions, memory leaks.
- **Security & Privacy**: SQL injection, XSS, unvalidated inputs, secret leaks, auth bypasses.
- **Performance & Scalability**: N+1 queries, unindexed filters, blocking I/O, heavy re-renders.
- **Maintainability & Clean Architecture**: Proper typing, single responsibility, clear error propagation.
- **Test Coverage**: Ensure all new code paths and edge cases have corresponding unit/integration tests.
