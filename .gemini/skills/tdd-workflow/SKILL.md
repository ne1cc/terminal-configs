---
name: tdd-workflow
description: Enforce Test-Driven Development (TDD) cycle (Red -> Green -> Refactor). Use when implementing new features, fixing bugs, or refactoring critical logic to ensure 100% test coverage and regression safety.
---

# Test-Driven Development (TDD) Workflow

## Core Principles
1. **Red**: Write a failing test FIRST that precisely defines the expected behavior, edge case, or bug reproduction. Run the test to confirm it fails for the expected reason.
2. **Green**: Write the minimal amount of production code necessary to make the failing test pass. Run tests to confirm all tests pass.
3. **Refactor**: Clean up the code, improve abstractions, and remove duplication while maintaining passing tests.
4. **Adversarial Edge Cases**: Test boundary conditions, null/undefined inputs, empty collections, concurrency races, and network failure modes.
