#!/usr/bin/env bash
# compile-mermaid.sh — Validate and compile .mmd diagram files to .svg via mmdc.
#
# Intent: Provides a 1-click T3 Code Quick Action and CLI helper to validate
#         Mermaid AST syntax and compile .mmd files into side-by-side .svg assets.
#
# Contract:
# - Returns 0 when no .mmd files exist or all .mmd files validate and compile cleanly.
# - Returns 1 with exact parser error lines if any .mmd file fails AST validation.
#
# Limits: Requires mmdc (@mermaid-js/mermaid-cli) or npx in PATH.

set -euo pipefail

# 1. Resolve mmdc binary (check PATH and standard Node/NVM paths before falling back to npx)
export PATH="$HOME/.nvm/versions/node/v24.16.0/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
MMDC_CMD=()
if command -v mmdc >/dev/null 2>&1; then
  MMDC_CMD=("$(command -v mmdc)")
elif command -v npx >/dev/null 2>&1; then
  MMDC_CMD=("npx" "-y" "@mermaid-js/mermaid-cli")
else
  printf 'Error: Neither mmdc nor npx found in PATH.\n' >&2
  exit 1
fi

# 2. Collect target .mmd files (explicit args or discovery in docs/diagrams and repo)
CHECK_ONLY=false
TARGETS=()
for arg in "$@"; do
  case "$arg" in
    --check) CHECK_ONLY=true ;;
    *) TARGETS+=("$arg") ;;
  esac
done

if [[ "${#TARGETS[@]}" -eq 0 ]]; then
  if command -v rg >/dev/null 2>&1; then
    while IFS= read -r f; do
      [[ -n "$f" ]] && TARGETS+=("$f")
    done < <(rg --files -g "*.mmd" 2>/dev/null || true)
  elif [[ -d "docs/diagrams" ]]; then
    for f in docs/diagrams/*.mmd; do
      [[ -f "$f" ]] && TARGETS+=("$f")
    done
  fi
fi

if [[ "${#TARGETS[@]}" -eq 0 ]]; then
  printf 'No .mmd files found in workspace (nothing to compile).\n'
  exit 0
fi

# 3. Validate and optionally compile each .mmd file to .svg
FAILED=0
for file in "${TARGETS[@]}"; do
  if [[ ! -f "$file" ]]; then
    printf 'Missing file: %s\n' "$file" >&2
    FAILED=1
    continue
  fi

  if "$CHECK_ONLY"; then
    out_svg="$(mktemp "${TMPDIR:-/tmp}/mermaid-check.XXXXXX.svg")"
    if ! "${MMDC_CMD[@]}" -i "$file" -o "$out_svg" >/dev/null 2>&1; then
      printf 'Mermaid syntax error in %s:\n' "$file" >&2
      "${MMDC_CMD[@]}" -i "$file" -o "$out_svg" || true
      FAILED=1
    else
      printf '[OK] Validated Mermaid AST: %s\n' "$file"
    fi
    rm -f "$out_svg"
  else
    out_svg="${file%.mmd}.svg"
    if ! "${MMDC_CMD[@]}" -i "$file" -o "$out_svg" >/dev/null 2>&1; then
      printf 'Mermaid syntax error in %s:\n' "$file" >&2
      "${MMDC_CMD[@]}" -i "$file" -o "$out_svg" || true
      FAILED=1
    else
      printf '[OK] Compiled %s -> %s\n' "$file" "$out_svg"
    fi
  fi
done

if [[ "$FAILED" -ne 0 ]]; then
  exit 1
fi
