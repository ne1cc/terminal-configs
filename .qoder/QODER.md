# QODER.md — Global Qoder Agent Instructions

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

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

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## Superpowers (Mandatory — Start of Every Session)

At the start of every conversation, read and follow the `using-superpowers` skill:

```
~/.qoder/skills/using-superpowers/SKILL.md
```

This skill establishes how to discover and invoke all relevant skills **before** any
response, action, or clarifying question. New feature? Use brainstorming.
Bug? Use systematic-debugging. Code review? There's a skill for that.

**This is non-negotiable.** Do not skip it. Do not assume you remember it.
Read it fresh every session.

## Platform: Qoder

Read `~/.qoder/skills/using-superpowers/references/qoder-tools.md` for
Qoder-specific tool mappings, if that file exists.

## High-Signal Code Commenting & Walkthrough Standard

When writing, documenting, or explaining non-trivial code (multi-step routines, async workflows, security/auth, state machines, or branching logic), structure comments and summaries to maximize architectural signal and eliminate syntax restatement.

### 1. In-Source Code Comments (Writing & Refactoring Code)
Do not restate syntax (`// calls foo()`). Structure comments in two concise tiers:

1. **Boundary Docblock (Intent + Contract + Limits)**:
   - **Intent**: 1 sentence stating what the function/module accomplishes.
   - **Contract**: Bulleted return and throw behavior (`Returns <type> on success`, `Returns fallback on missing/stale`, `Throws/Rejects on ...`).
   - **Limits**: Non-obvious invariants, helper assumptions, concurrency bounds, or `shortcut: <limit>, <when to upgrade>`.
2. **Numbered Step Comments (`// 1.`, `// 2.`, ...)**:
   - Group sequential blocks under numbered headings that fuse the action with the decision rule (`Condition → Action`).
   - State the **why** the code cannot show: race-condition guards (e.g. session swaps during pending `await`), conditional write invariants, or status-code rationale (`401` vs transient error).

```js
/**
 * Returns a usable access token, refreshing if expired.
 *
 * Contract:
 * - Returns token string when valid or refreshed; "" when signed out, superseded, or refresh fails.
 * - Rejects only if initial readSession() or catch-block cleanup throws.
 *
 * Limits: Does not deduplicate concurrent callers; relies on writeSession() enforcing CAS.
 */
async function refreshAccessToken() {
  // 1. Load current session (missing session or token → bail without refresh)
  const session = await readSession();
  if (!session || !session.access) return "";

  // 2. Reuse cached token if unexpired locally (avoids network round-trip)
  if (session.accessExpiresAt > Date.now()) return session.access;

  try {
    // 3. Exchange refresh token for updated credentials (server may rotate token)
    const refreshed = sessionFrom(
      await api("/api/auth/refresh", { body: { refresh_token: session.refresh } }),
      session
    );

    // 4. Guard against mid-flight sign-out or account switch while network await was pending
    if ((await readSession())?.refresh !== session.refresh) return "";

    // 5. Commit conditionally: save only if stored session still matches original { id, refresh }
    const committed = await writeSession(refreshed, { id: session.id, refresh: session.refresh });
    return committed ? committed.access : "";
  } catch (err) {
    // 6. Handle refresh failure:
    // - 401 + same session → refresh token revoked/expired; clear session
    // - Transient error (offline/5xx) → keep stored session for later retry
    if (err.status === 401 && (await readSession())?.refresh === session.refresh) {
      await clearSession(session.id);
    }
    return "";
  }
}
```

### 2. Code Walkthroughs & Summaries (Chat, PRs & Docs)
When summarizing or explaining code to humans:
1. **Executive Intent & Return Contract**: 1–2 sentences on purpose plus bulleted return/error outcomes.
2. **Numbered Block-by-Block Walkthrough (`## 1. ...`)**: Isolate each block, explain data shapes, provide a monospace `Condition → Action` truth table, and detail the async/state transition sequence.
3. **Control-Flow Tree**: Compact Unicode tree (`├─` / `└─`) showing the decision gates and exit points.
4. **Important Limits**: Bulleted list of helper assumptions, concurrency gaps, and uncaught error boundaries.

## Ponytail by default

For every coding task (writing, fixing, refactoring, reviewing, or choosing dependencies), read and follow `~/.qoder/skills/ponytail/SKILL.md` before starting work. Ponytail is active by default at full level. Honor explicit requests to change the level or disable Ponytail for the session.
