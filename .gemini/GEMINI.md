# Markdown & Equation Formatting Rules for Antigravity

When generating or editing Markdown (`.md`) documents, notes, cheat sheets, or responses:

## 1. No Raw LaTeX Math Tags
- NEVER use raw LaTeX math delimiters or environments (`$$ ... $$`, `$...$`, `\text{...}`, `\frac{...}{...}`, `\le`, `\ge`, `\Delta`, `\sum`, `\rightarrow`).
- Many Markdown viewers (such as One Markdown, VS Code Markdown Preview, GitHub Markdown) do not enable LaTeX MathJax by default, causing raw tags to render as broken, unreadable code.

## 2. Monospace Calculation & Formula Blocks
- For all multi-step calculations, equations, summation proofs, and ratios, ALWAYS use clean fenced monospace code blocks:
  ```
  Total % Change = ∑ (Percentage Change_k)
                 = (Actual Change_1 / Allowable Change_1) + ...
                 = 50% + 75% = 125% > 100%
  ```
- Use code blocks for financial calculations:
  ```
  ΔProfit = (-8 hrs × $10.00/hr) + (+30 yds × $5.00/yd)
          = -$80 + $150
          = +$70.00
  ```

## 3. Native Unicode Typography
- Use standard native Unicode symbols for mathematical and logical expressions:
  - Inequality: `≤`, `≥`, `≠`, `≈`
  - Operations: `∑`, `×`, `÷`, `√N`, `±`
  - Greek / Derivatives: `Δ`, `μ`, `σ`, `λ`, `∈`
  - Arrows & Logic: `→`, `⇒`, `↔`, `⇔`

## 4. Currency vs. Math Collision Prevention
- Dollar signs (`$`) must NEVER be used as LaTeX math delimiters.
- When referencing currency, format values inside backtick code spans:
  - Correct: `$10.00/hr`, `-$8.00`, `$5.00/yd`
  - Incorrect: `$10.00/hr$` or `$$10.00$$`

## 5. Inline Variables & Expressions
- Wrap variable names, parameters, and short inline formulas in backtick code spans:
  - Examples: `x*`, `Δc_j`, `Q*`, `RiskTriang(100, 160, 220)`, `P* = 10/19 = 52.6%`.

## 6. Session Resumption & Handoffs
- When asked to "resume", "continue", or "pick up where we left off", always check `.gemini/sessions/` or `~/.gemini/sessions/` for the latest dated session handoff document to instantly restore context, working branch, uncommitted diffs, and the open tasks roadmap.

## GitHub Namespace Layout & Shortcuts (mandatory)

Local disk mirrors GitHub by owner. Primary account is `n1ecC`.

```text
~/Github/
  n1ecC/                 # ONLY repos that exist on github.com/n1ecC/*
  _local/projects/       # local WIP with no remote yet
  _local/archive/        # old / non-synced trees
  _local/worktrees/      # linked git worktrees
  <other-owner>/         # reference clones (do not add to .mirror-owners)
  .mirror-owners         # synced owners list (currently: n1ecC)
```

### Shell aliases (prefer these over raw git/gh for repo placement)

| Alias | Command | Use when |
|-------|---------|----------|
| `gnn <name>` | `gh-ns-new` | Start a **local-only** project in `~/Github/_local/projects/<name>` (`--python` / `--node` optional) |
| `gnp` | `gh-ns-promote` | Promote cwd (or path) → create `n1ecC/<name>` on GitHub, push, **move** into `~/Github/n1ecC/<name>` (`--public`, `--name`, `--owner`) |
| `gns` | `gh-ns-status` | Show local WIP + mirror drift |
| `gmc` | `gh-mirror-check` | Compare `n1ecC` remotes vs `~/Github/n1ecC` (`MISSING` / `ORPHAN`) |
| `gnc owner/repo` | `gh-ns-clone` | Clone into `~/Github/<owner>/<repo>` |
| `gnf owner/repo` | `gh-ns-fork` | Fork to your account, clone under your namespace; `origin`=fork, `upstream`=original |

### Happy path
```bash
gnn invoice-etl --python
cd ~/Github/_local/projects/invoice-etl
# commit work…
gnp
cd ~/Github/n1ecC/invoice-etl
gmc
```

### Rules agents must follow
1. Never invent a flat `~/Github/<repo>` path. Synced remotes live under `~/Github/n1ecC/<repo>`.
2. New work with no GitHub remote yet → `gnn` / `_local/projects/`, then `gnp` when ready to publish.
3. After `gnp`, the canonical path is `~/Github/n1ecC/<repo>`; do not leave promoted repos under `_local`.
4. Do not add third-party orgs (e.g. `facebook`) to `.mirror-owners`. Use `gnc` for read-only clones; `gnf` to contribute.
5. Before promote/push: ensure `.gitignore` covers `.venv/`, `node_modules/`, `.env`, large data; never commit secrets.
6. Prefer `gmc` / `gns` to verify layout instead of ad-hoc `find` when diagnosing missing clones.
