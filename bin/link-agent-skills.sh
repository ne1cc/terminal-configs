#!/usr/bin/env bash
# link-agent-skills.sh — symlink portable agent skills to all agent runtime directories
#                        and bootstrap global agent instruction files.
#
# Shared skills (.gemini/skills) are linked into:
#   ~/.gemini/config/skills   (Antigravity / Gemini CLI)
#   ~/.claude/skills          (Claude Code)
#   ~/.agents/skills          (cross-runtime alias: Copilot CLI, Gemini)
#   ~/.qoder/skills           (Qoder CLI)
#   ~/.codex/skills           (Codex / ChatGPT)
#
# Cursor-only skills (.cursor/skills-cursor) → ~/.cursor/skills-cursor/
# Cursor rules (.cursor/rules/*.mdc)         → ~/.cursor/rules/
#
# Global instruction files bootstrapped (if absent):
#   ~/.codex/AGENTS.md        (instructs Codex to invoke using-superpowers at session start)
#   ~/.qoder/QODER.md         (instructs Qoder to invoke using-superpowers at session start)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

link_skill_tree() {
  local source_root="$1"
  shift
  local -a dest_roots=("$@")
  local skill dest_root name dest count=0

  [[ -d "$source_root" ]] || return 0

  for skill in "$source_root"/*; do
    [[ -d "$skill" ]] || continue
    name="$(basename "$skill")"
    for dest_root in "${dest_roots[@]}"; do
      dest="$dest_root/$name"
      mkdir -p "$dest_root"
      if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ -L "$dest" && "$(readlink "$dest")" == "$skill" ]]; then
          continue
        fi
        rm -rf "$dest"
      fi
      ln -sfn "$skill" "$dest"
    done
    count=$((count + 1))
  done

  printf '  linked %d skills from %s\n' "$count" "$source_root"
}

printf '==> Linking agent skills from %s\n' "$REPO_DIR"

mkdir -p "$HOME/.gemini/config" "$HOME/.claude/skills" "$HOME/.agents/skills" "$HOME/.cursor/skills-cursor" "$HOME/.qoder/skills"

if [[ -f "$REPO_DIR/.gemini/GEMINI.md" ]]; then
  ln -sfn "$REPO_DIR/.gemini/GEMINI.md" "$HOME/GEMINI.md"
  ln -sfn "$REPO_DIR/.gemini/GEMINI.md" "$HOME/.gemini/GEMINI.md"
  ln -sfn "$REPO_DIR/.gemini/GEMINI.md" "$HOME/.gemini/config/GEMINI.md"
  printf '  linked GEMINI.md (Home, ~/.gemini, and ~/.gemini/config)\n'
fi

if [[ -f "$REPO_DIR/AGENTS.md" ]]; then
  mkdir -p "$HOME/.qoder" "$HOME/.agents"
  ln -sfn "$REPO_DIR/AGENTS.md" "$HOME/.qoder/AGENTS.md"
  ln -sfn "$REPO_DIR/AGENTS.md" "$HOME/.agents/AGENTS.md"
  printf '  linked AGENTS.md (~/.qoder and ~/.agents)\n'
fi

link_skill_tree "$REPO_DIR/.gemini/skills" \
  "$HOME/.gemini/config/skills" \
  "$HOME/.claude/skills" \
  "$HOME/.agents/skills" \
  "$HOME/.qoder/skills" \
  "$HOME/.codex/skills"

link_skill_tree "$REPO_DIR/.claude/skills" "$HOME/.claude/skills"
link_skill_tree "$REPO_DIR/.cursor/skills-cursor" "$HOME/.cursor/skills-cursor"

# Link .cursor/rules/*.mdc into ~/.cursor/rules/
if [[ -d "$REPO_DIR/.cursor/rules" ]]; then
  mkdir -p "$HOME/.cursor/rules"
  for rule in "$REPO_DIR/.cursor/rules"/*.mdc; do
    [[ -f "$rule" ]] || continue
    dest="$HOME/.cursor/rules/$(basename "$rule")"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$rule" ]]; then
      continue
    fi
    ln -sfn "$rule" "$dest"
  done
  printf '  linked cursor rules from %s\n' "$REPO_DIR/.cursor/rules"
fi

if [[ -f "$REPO_DIR/.gemini/hooks.json" ]]; then
  ln -sfn "$REPO_DIR/.gemini/hooks.json" "$HOME/.gemini/config/hooks.json"
  printf '  linked hooks.json (~/.gemini/config/hooks.json)\n'
fi

# Ensure workmux does not prompt to install broken Antigravity lifecycle hooks
mkdir -p "$HOME/.local/state/workmux"
if [[ -f "$HOME/.local/state/workmux/setup.json" ]]; then
  if ! grep -q '"agy"' "$HOME/.local/state/workmux/setup.json" 2>/dev/null; then
    printf '{\n  "declined": ["agy"],\n  "declined_skills": []\n}\n' > "$HOME/.local/state/workmux/setup.json"
  fi
else
  printf '{\n  "declined": ["agy"],\n  "declined_skills": []\n}\n' > "$HOME/.local/state/workmux/setup.json"
fi

# ── Codex: link global AGENTS.md from repo (or bootstrap) ───────────────────
if [[ -f "$REPO_DIR/.codex/AGENTS.md" ]]; then
  mkdir -p "$HOME/.codex"
  ln -sfn "$REPO_DIR/.codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
  printf '  linked: %s -> %s\n' "$HOME/.codex/AGENTS.md" "$REPO_DIR/.codex/AGENTS.md"
fi

# ── Qoder: link global QODER.md from repo (or bootstrap) ────────────────────
if [[ -f "$REPO_DIR/.qoder/QODER.md" ]]; then
  mkdir -p "$HOME/.qoder"
  ln -sfn "$REPO_DIR/.qoder/QODER.md" "$HOME/.qoder/QODER.md"
  printf '  linked: %s -> %s\n' "$HOME/.qoder/QODER.md" "$REPO_DIR/.qoder/QODER.md"
fi

# ── Claude Code: seed ~/.claude/settings.json with required permissions ───────
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if command -v python3 >/dev/null 2>&1 && [[ -f "$CLAUDE_SETTINGS" ]]; then
  python3 - "$CLAUDE_SETTINGS" <<'PY_EOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
perms = data.setdefault("permissions", {})
allow = perms.setdefault("allow", [])
added = []
for entry in ["Bash(gh pr merge:*)"]:
    if entry not in allow:
        allow.append(entry)
        added.append(entry)
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
if added:
    print(f"  seeded ~/.claude/settings.json permissions: {added}")
else:
    print("  unchanged: ~/.claude/settings.json permissions already set")
PY_EOF
fi

printf 'Done linking agent skills.\n'
