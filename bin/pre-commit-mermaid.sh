#!/usr/bin/env bash
# pre-commit-mermaid.sh — Git pre-commit hook to validate staged .mmd files.
#
# Intent: Blocks commits containing broken Mermaid syntax while adding 0ms overhead
#         when no .mmd files are staged.
#
# Contract:
# - Exits 0 immediately if zero .mmd files are staged.
# - Delegates staged .mmd files to bin/compile-mermaid.sh --check.

set -euo pipefail

# 1. Collect staged .mmd files (excluding deleted files) -> bail early if none
STAGED_MMD=()
while IFS= read -r line; do
  [[ -n "$line" ]] && STAGED_MMD+=("$line")
done < <(git diff --cached --name-only --diff-filter=d | grep -E '\.mmd$' || true)

if [[ "${#STAGED_MMD[@]}" -eq 0 ]]; then
  exit 0
fi

# 2. Locate compile-mermaid.sh validator
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/compile-mermaid.sh"
if [[ ! -x "$VALIDATOR" && -x "$HOME/Github/ne1cc/terminal-configs/bin/compile-mermaid.sh" ]]; then
  VALIDATOR="$HOME/Github/ne1cc/terminal-configs/bin/compile-mermaid.sh"
fi

printf 'Validating %d staged Mermaid (.mmd) file(s)...\n' "${#STAGED_MMD[@]}"
"$VALIDATOR" --check "${STAGED_MMD[@]}"
