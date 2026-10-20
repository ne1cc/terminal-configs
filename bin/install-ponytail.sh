#!/usr/bin/env bash
# install-ponytail.sh — Install and configure Ponytail for all coding agents.
#
# Supported coding agents:
#   - OpenCode / T3 Code  (~/.config/opencode/opencode.json plugin, skills, commands)
#   - Codex               (~/.codex/skills, marketplace & plugin add, AGENTS.md)
#   - Claude Code         (~/.claude/skills, commands, CLAUDE.md)
#   - Antigravity / Gemini (~/.gemini/config/skills, agy/gemini extensions, GEMINI.md)
#   - Cursor              (~/.cursor/rules, skills-cursor, cursor-hooks)
#   - Qoder               (~/.qoder/skills, QODER.md, AGENTS.md)
#   - Copilot CLI         (~/.agents/skills, copilot plugin marketplace/install, AGENTS.md)
#
# Usage:
#   ./bin/install-ponytail.sh [--dry-run]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      echo "Usage: $0 [--dry-run]"
      exit 0
      ;;
  esac
done

run() {
  if "$DRY_RUN"; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

info() {
  printf '==> %s\n' "$1"
}

ok() {
  printf '  [ok] %s\n' "$1"
}

info "Installing Ponytail across all coding agents from $REPO_DIR"

# ── 1. Portable Skill Trees ──────────────────────────────────────────────────
PONYTAIL_SKILLS=(
  "ponytail"
  "ponytail-audit"
  "ponytail-debt"
  "ponytail-gain"
  "ponytail-help"
  "ponytail-review"
)

DEST_DIRS=(
  "$HOME/.gemini/config/skills"
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"
  "$HOME/.qoder/skills"
  "$HOME/.codex/skills"
  "$HOME/.config/opencode/skills"
  "$HOME/.cursor/skills-cursor"
)

for dest_root in "${DEST_DIRS[@]}"; do
  run mkdir -p "$dest_root"
  for sname in "${PONYTAIL_SKILLS[@]}"; do
    src="$REPO_DIR/.gemini/skills/$sname"
    [[ -d "$src" ]] || continue
    dest="$dest_root/$sname"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      continue
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
      run rm -rf "$dest"
    fi
    run ln -sfn "$src" "$dest"
  done
done
ok "Skills linked to all agent runtime directories."

# ── 2. Slash Commands (Claude Code & OpenCode) ────────────────────────────────
run mkdir -p "$HOME/.claude/commands" "$HOME/.config/opencode/command"

if [[ -d "$REPO_DIR/claude-code/commands" ]]; then
  for cmd in "$REPO_DIR/claude-code/commands"/ponytail*.md; do
    [[ -f "$cmd" ]] || continue
    cname="$(basename "$cmd")"
    run ln -sfn "$cmd" "$HOME/.claude/commands/$cname"
  done
  ok "Claude Code slash commands linked to ~/.claude/commands/"
fi

if [[ -d "$REPO_DIR/.opencode/command" ]]; then
  for cmd in "$REPO_DIR/.opencode/command"/ponytail*.md; do
    [[ -f "$cmd" ]] || continue
    cname="$(basename "$cmd")"
    run ln -sfn "$cmd" "$HOME/.config/opencode/command/$cname"
  done
  ok "OpenCode slash commands linked to ~/.config/opencode/command/"
fi

# ── 3. Cursor Rules ──────────────────────────────────────────────────────────
if [[ -f "$REPO_DIR/.cursor/rules/ponytail.mdc" ]]; then
  run mkdir -p "$HOME/.cursor/rules"
  run ln -sfn "$REPO_DIR/.cursor/rules/ponytail.mdc" "$HOME/.cursor/rules/ponytail.mdc"
  ok "Cursor rule linked to ~/.cursor/rules/ponytail.mdc"
fi

# ── 4. OpenCode / T3 Code Plugin Configuration ───────────────────────────────
OPENCODE_DIR="$HOME/.config/opencode"
OPENCODE_CONFIG="$OPENCODE_DIR/opencode.json"
run mkdir -p "$OPENCODE_DIR"

if command -v python3 >/dev/null 2>&1; then
  python3 - "$OPENCODE_CONFIG" "$DRY_RUN" <<'PY_EOF'
import json, os, sys

config_path, dry_run = sys.argv[1], (sys.argv[2].lower() == "true")
data = {}
if os.path.exists(config_path):
    try:
        with open(config_path) as f:
            data = json.load(f)
    except Exception:
        data = {}

plugin_key = "plugin" if "plugin" in data else ("plugins" if "plugins" in data else "plugin")
plugins = data.setdefault(plugin_key, [])
target = "@dietrichgebert/ponytail"

if target not in plugins:
    plugins.append(target)
    if not dry_run:
        with open(config_path, "w") as f:
            json.dump(data, f, indent=2)
            f.write("\n")
        print("  [ok] Configured @dietrichgebert/ponytail in ~/.config/opencode/opencode.json")
    else:
        print("  [dry-run] Would configure @dietrichgebert/ponytail in ~/.config/opencode/opencode.json")
else:
    print("  [ok] @dietrichgebert/ponytail already configured in ~/.config/opencode/opencode.json")
PY_EOF
fi

# Ensure npm package is installed in ~/.config/opencode for node resolution
if command -v npm >/dev/null 2>&1 && [[ -d "$OPENCODE_DIR" ]]; then
  if [[ ! -d "$OPENCODE_DIR/node_modules/@dietrichgebert/ponytail" ]]; then
    if ! "$DRY_RUN"; then
      (cd "$OPENCODE_DIR" && npm install --no-audit --no-fund @dietrichgebert/ponytail >/dev/null 2>&1 || true)
      ok "Installed @dietrichgebert/ponytail package in ~/.config/opencode"
    else
      printf '  [dry-run] npm install @dietrichgebert/ponytail in ~/.config/opencode\n'
    fi
  else
    ok "Package @dietrichgebert/ponytail already present in ~/.config/opencode/node_modules"
  fi
fi

# OpenCode CLI global plugin registration if binary is present
OPENCODE_BIN=""
if command -v opencode >/dev/null 2>&1; then
  OPENCODE_BIN="$(command -v opencode)"
elif [[ -x "$HOME/.opencode/bin/opencode" ]]; then
  OPENCODE_BIN="$HOME/.opencode/bin/opencode"
fi

if [[ -n "$OPENCODE_BIN" ]]; then
  if ! "$DRY_RUN"; then
    "$OPENCODE_BIN" plugin -g @dietrichgebert/ponytail >/dev/null 2>&1 || true
    ok "OpenCode CLI registered global plugin: @dietrichgebert/ponytail"
  else
    printf '  [dry-run] %s plugin -g @dietrichgebert/ponytail\n' "$OPENCODE_BIN"
  fi
fi

# ── 5. Codex Plugin ──────────────────────────────────────────────────────────
if command -v codex >/dev/null 2>&1; then
  if ! "$DRY_RUN"; then
    codex plugin marketplace add DietrichGebert/ponytail >/dev/null 2>&1 || true
    codex plugin add ponytail@ponytail >/dev/null 2>&1 || true
    ok "Codex plugin added: ponytail@ponytail"
  else
    printf '  [dry-run] codex plugin marketplace add DietrichGebert/ponytail\n'
    printf '  [dry-run] codex plugin add ponytail@ponytail\n'
  fi
else
  ok "Codex CLI not in PATH (skills and AGENTS.md linked for Codex)"
fi

# ── 6. Gemini CLI / Antigravity CLI ──────────────────────────────────────────
if command -v gemini >/dev/null 2>&1; then
  if ! "$DRY_RUN"; then
    gemini extensions install https://github.com/DietrichGebert/ponytail >/dev/null 2>&1 || true
    ok "Gemini CLI extension installed: DietrichGebert/ponytail"
  else
    printf '  [dry-run] gemini extensions install https://github.com/DietrichGebert/ponytail\n'
  fi
fi

if command -v agy >/dev/null 2>&1; then
  if ! "$DRY_RUN"; then
    agy plugin install https://github.com/DietrichGebert/ponytail >/dev/null 2>&1 || true
    ok "Antigravity CLI plugin installed: DietrichGebert/ponytail"
  else
    printf '  [dry-run] agy plugin install https://github.com/DietrichGebert/ponytail\n'
  fi
fi

# ── 7. GitHub Copilot CLI ───────────────────────────────────────────────────
if command -v copilot >/dev/null 2>&1; then
  if ! "$DRY_RUN"; then
    copilot plugin marketplace add DietrichGebert/ponytail >/dev/null 2>&1 || true
    copilot plugin install ponytail@ponytail >/dev/null 2>&1 || true
    ok "Copilot CLI plugin installed: ponytail@ponytail"
  else
    printf '  [dry-run] copilot plugin marketplace add DietrichGebert/ponytail\n'
    printf '  [dry-run] copilot plugin install ponytail@ponytail\n'
  fi
fi

# ── 8. Cursor Hooks (Optional / if package checkout exists) ──────────────────
CURSOR_HOOK_SCRIPT=""
if [[ -f "$OPENCODE_DIR/node_modules/@dietrichgebert/ponytail/scripts/cursor-hooks.js" ]]; then
  CURSOR_HOOK_SCRIPT="$OPENCODE_DIR/node_modules/@dietrichgebert/ponytail/scripts/cursor-hooks.js"
fi

if [[ -n "$CURSOR_HOOK_SCRIPT" ]] && command -v node >/dev/null 2>&1; then
  if ! "$DRY_RUN"; then
    node "$CURSOR_HOOK_SCRIPT" install >/dev/null 2>&1 || true
    ok "Cursor hooks installed via cursor-hooks.js"
  else
    printf '  [dry-run] node %s install\n' "$CURSOR_HOOK_SCRIPT"
  fi
fi

info "Ponytail installation complete across all coding agents."
