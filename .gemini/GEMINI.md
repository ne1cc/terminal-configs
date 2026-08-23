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
