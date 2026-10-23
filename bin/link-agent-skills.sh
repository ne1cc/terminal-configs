#!/usr/bin/env bash
# link-agent-skills.sh — symlink portable agent skills to all agent runtime directories,
#                        bootstrap global agent instruction files, configure T3 Code quality
#                        engine settings, and verify system-wide integrity.
#
# Shared skills (.gemini/skills) are linked into:
#   ~/.gemini/config/skills   (Antigravity / Gemini CLI)
#   ~/.claude/skills          (Claude Code primary)
#   ~/.claude-secondary/skills (Claude Code secondary)
#   ~/.agents/skills          (cross-runtime alias: Copilot CLI, Gemini, T3)
#   ~/.qoder/skills           (Qoder CLI)
#   ~/.codex/skills           (Codex / ChatGPT)
#   ~/.config/opencode/skills (OpenCode / T3 Code)
#   ~/.opencode/skills        (OpenCode legacy path)
#   ~/.t3/skills              (T3 Code global skills)
#   ~/.cursor/skills-cursor   (Cursor IDE)
#   ~/.t3/userdata/providers/antigravity/*/config/skills (T3 Antigravity ACP instances)
#
# Global instruction files:
#   ~/AGENTS.md & ~/.agents/AGENTS.md -> AGENTS.md
#   ~/.codex/AGENTS.md                -> .codex/AGENTS.md
#   ~/.qoder/QODER.md                 -> .qoder/QODER.md
#   ~/.config/opencode/AGENTS.md      -> .opencode/AGENTS.md
#   ~/.opencode/AGENTS.md             -> ~/.config/opencode/AGENTS.md
#   ~/.claude/CLAUDE.md               -> claude-code/CLAUDE.md
#   ~/.claude-secondary/CLAUDE.md     -> claude-code/CLAUDE.md
#   ~/.gemini/GEMINI.md               -> .gemini/GEMINI.md
#   ~/.t3/AGENTS.md                   -> ~/.agents/AGENTS.md
#   ~/.t3/CLAUDE.md                   -> ~/.claude/CLAUDE.md
#   ~/.t3/GEMINI.md                   -> ~/.gemini/GEMINI.md
#   ~/.t3/userdata/providers/antigravity/*/GEMINI.md -> ~/.gemini/GEMINI.md
#
# Usage:
#   ./bin/link-agent-skills.sh          # Link all files, configure T3 settings, run verify
#   ./bin/link-agent-skills.sh --verify # Verification assertion only (exit 0 or 1)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERIFY_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --verify) VERIFY_ONLY=true ;;
    -h|--help)
      echo "Usage: $0 [--verify]"
      exit 0
      ;;
  esac
done

# ── Verification Function ───────────────────────────────────────────────────
verify_configs() {
  local errors=0
  printf '==> Verifying agent configs and symlinks from %s\n' "$REPO_DIR"

  # 1. Verify 6 instruction files exist and size < 20000 bytes
  local files=(
    "$REPO_DIR/AGENTS.md"
    "$REPO_DIR/.codex/AGENTS.md"
    "$REPO_DIR/.opencode/AGENTS.md"
    "$REPO_DIR/claude-code/CLAUDE.md"
    "$REPO_DIR/.gemini/GEMINI.md"
    "$REPO_DIR/.qoder/QODER.md"
  )
  for f in "${files[@]}"; do
    if [[ ! -f "$f" ]]; then
      printf '  [FAIL] Missing instruction file: %s\n' "$f"
      errors=$((errors + 1))
      continue
    fi
    local sz
    sz="$(wc -c < "$f" | tr -d ' ')"
    if [[ "$sz" -ge 20000 ]]; then
      printf '  [FAIL] %s exceeds T3 20KB limit (%d bytes >= 20000)\n' "$(basename "$f")" "$sz"
      errors=$((errors + 1))
    else
      printf '  [OK] %-25s %5d bytes (< 20000 bytes limit)\n' "$(basename "$f")" "$sz"
    fi
  done

  # 2. Verify key symlinks resolve
  local symlinks=(
    "$HOME/AGENTS.md"
    "$HOME/.agents/AGENTS.md"
    "$HOME/.codex/AGENTS.md"
    "$HOME/.qoder/QODER.md"
    "$HOME/.config/opencode/AGENTS.md"
    "$HOME/.opencode/AGENTS.md"
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.gemini/GEMINI.md"
    "$HOME/.t3/AGENTS.md"
    "$HOME/.t3/CLAUDE.md"
    "$HOME/.t3/GEMINI.md"
    "$HOME/.t3/skills"
    "$HOME/.agents/skills/mermaid-lens/SKILL.md"
    "$HOME/.t3/skills/mermaid-lens/SKILL.md"
  )
  for link in "${symlinks[@]}"; do
    if [[ -e "$link" ]]; then
      printf '  [OK] Link valid: %s\n' "$link"
    else
      printf '  [FAIL] Broken or missing link: %s\n' "$link"
      errors=$((errors + 1))
    fi
  done

  # 3. Verify T3 settings.json schema compliance
  local t3_settings="$HOME/.t3/userdata/settings.json"
  if [[ -f "$t3_settings" ]]; then
    if python3 - "$t3_settings" <<'PY_EOF' >/dev/null 2>&1
import json, sys
with open(sys.argv[1]) as f:
    d = json.load(f)
assert d.get("reviewGuidesEnabled") is True, "reviewGuidesEnabled not True"
assert "reviewGuideInstructions" in d, "missing reviewGuideInstructions"
sc = d.get("sourceControlWritingStyle", {})
assert sc.get("mode") == "custom", "sourceControlWritingStyle.mode not custom"
assert sc.get("followChangeRequestTemplates") is True, "followChangeRequestTemplates not True"
scripts = d.get("defaultProjectScripts", [])
script_ids = [s.get("id") for s in scripts]
for req in ["sync-agent-configs", "ponytail-debt-ledger", "compile-mermaid-diagrams", "verify-agent-configs"]:
    assert req in script_ids, f"missing defaultProjectScript {req}"
PY_EOF
    then
      printf '  [OK] T3 Code settings.json schema & quality keys verified\n'
    else
      printf '  [FAIL] T3 Code settings.json missing required quality keys\n'
      errors=$((errors + 1))
    fi
  fi

  if [[ "$errors" -eq 0 ]]; then
    printf 'All verification checks PASSED.\n'
    return 0
  else
    printf 'Verification FAILED with %d error(s).\n' "$errors"
    return 1
  fi
}

if "$VERIFY_ONLY"; then
  verify_configs
  exit $?
fi

# ── Symlinking Logic ────────────────────────────────────────────────────────
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

printf '==> Linking agent skills and instruction files from %s\n' "$REPO_DIR"

mkdir -p "$HOME/.gemini/config" \
  "$HOME/.claude/skills" \
  "$HOME/.claude-secondary/skills" \
  "$HOME/.agents/skills" \
  "$HOME/.cursor/skills-cursor" \
  "$HOME/.qoder/skills" \
  "$HOME/.codex/skills" \
  "$HOME/.config/opencode/skills" \
  "$HOME/.opencode" \
  "$HOME/.t3"

# ── 1. Root & Host Instruction Symlinks ───────────────────────────────────────
if [[ -f "$REPO_DIR/.gemini/GEMINI.md" ]]; then
  ln -sfn "$REPO_DIR/.gemini/GEMINI.md" "$HOME/GEMINI.md"
  ln -sfn "$REPO_DIR/.gemini/GEMINI.md" "$HOME/.gemini/GEMINI.md"
  ln -sfn "$REPO_DIR/.gemini/GEMINI.md" "$HOME/.gemini/config/GEMINI.md"
  ln -sfn "$HOME/.gemini/GEMINI.md" "$HOME/.t3/GEMINI.md"
  printf '  linked GEMINI.md (Home, ~/.gemini, ~/.gemini/config, and ~/.t3)\n'
fi

if [[ -f "$REPO_DIR/AGENTS.md" ]]; then
  mkdir -p "$HOME/.qoder" "$HOME/.agents"
  ln -sfn "$REPO_DIR/AGENTS.md" "$HOME/.agents/AGENTS.md"
  ln -sfn "$HOME/.agents/AGENTS.md" "$HOME/AGENTS.md"
  ln -sfn "$HOME/.agents/AGENTS.md" "$HOME/.t3/AGENTS.md"
  ln -sfn "$REPO_DIR/AGENTS.md" "$HOME/.qoder/AGENTS.md"
  printf '  linked AGENTS.md (Home, ~/.agents, ~/.t3, and ~/.qoder)\n'
fi

if [[ -f "$REPO_DIR/claude-code/CLAUDE.md" ]]; then
  mkdir -p "$HOME/.claude" "$HOME/.claude-secondary"
  ln -sfn "$REPO_DIR/claude-code/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  ln -sfn "$REPO_DIR/claude-code/CLAUDE.md" "$HOME/.claude-secondary/CLAUDE.md"
  ln -sfn "$HOME/.claude/CLAUDE.md" "$HOME/.t3/CLAUDE.md"
  printf '  linked CLAUDE.md (~/.claude, ~/.claude-secondary, and ~/.t3)\n'
fi

if [[ -f "$REPO_DIR/.codex/AGENTS.md" ]]; then
  mkdir -p "$HOME/.codex"
  ln -sfn "$REPO_DIR/.codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
  printf '  linked .codex/AGENTS.md (~/.codex/AGENTS.md)\n'
fi

if [[ -f "$REPO_DIR/.qoder/QODER.md" ]]; then
  mkdir -p "$HOME/.qoder"
  ln -sfn "$REPO_DIR/.qoder/QODER.md" "$HOME/.qoder/QODER.md"
  printf '  linked .qoder/QODER.md (~/.qoder/QODER.md)\n'
fi

if [[ -f "$REPO_DIR/.opencode/AGENTS.md" ]]; then
  mkdir -p "$HOME/.config/opencode" "$HOME/.opencode"
  ln -sfn "$REPO_DIR/.opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
  ln -sfn "$HOME/.config/opencode/AGENTS.md" "$HOME/.opencode/AGENTS.md"
  if [[ -f "$REPO_DIR/.opencode/opencode.json" ]]; then
    ln -sfn "$REPO_DIR/.opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
    ln -sfn "$HOME/.config/opencode/opencode.json" "$HOME/.opencode/opencode.json"
  fi
  printf '  linked OpenCode AGENTS.md & opencode.json (~/.config/opencode and ~/.opencode)\n'
fi

# ── 2. T3 Antigravity Provider Instances ─────────────────────────────────────
T3_AGY_PROVIDERS_DIR="$HOME/.t3/userdata/providers/antigravity"
if [[ -d "$T3_AGY_PROVIDERS_DIR" ]]; then
  for pdir in "$T3_AGY_PROVIDERS_DIR"/*; do
    [[ -d "$pdir" ]] || continue
    mkdir -p "$pdir/config"
    ln -sfn "$HOME/.gemini/GEMINI.md" "$pdir/GEMINI.md"
    ln -sfn "$HOME/.gemini/GEMINI.md" "$pdir/config/GEMINI.md"
    ln -sfn "$REPO_DIR/.gemini/skills" "$pdir/config/skills"
    if [[ -d "$HOME/.gemini/config/plugins" ]]; then
      ln -sfn "$HOME/.gemini/config/plugins" "$pdir/config/plugins"
    fi
    if [[ -f "$REPO_DIR/.gemini/hooks.json" ]]; then
      ln -sfn "$REPO_DIR/.gemini/hooks.json" "$pdir/config/hooks.json"
    fi
  done
  printf '  linked Antigravity configs and skills into all T3 ACP provider instances\n'
fi

# ── 3. Skills Trees ──────────────────────────────────────────────────────────
ln -sfn "$REPO_DIR/.gemini/skills" "$HOME/.t3/skills"
ln -sfn "$HOME/.config/opencode/skills" "$HOME/.opencode/skills"

link_skill_tree "$REPO_DIR/.gemini/skills" \
  "$HOME/.gemini/config/skills" \
  "$HOME/.claude/skills" \
  "$HOME/.claude-secondary/skills" \
  "$HOME/.agents/skills" \
  "$HOME/.qoder/skills" \
  "$HOME/.codex/skills" \
  "$HOME/.config/opencode/skills" \
  "$HOME/.cursor/skills-cursor"

link_skill_tree "$REPO_DIR/.claude/skills" \
  "$HOME/.claude/skills" \
  "$HOME/.claude-secondary/skills" \
  "$HOME/.config/opencode/skills"

link_skill_tree "$REPO_DIR/.cursor/skills-cursor" "$HOME/.cursor/skills-cursor"

# Cursor rules & OpenCode commands
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

if [[ -d "$REPO_DIR/.opencode/command" ]]; then
  mkdir -p "$HOME/.config/opencode/command"
  for cmd in "$REPO_DIR/.opencode/command"/*.md; do
    [[ -f "$cmd" ]] || continue
    dest="$HOME/.config/opencode/command/$(basename "$cmd")"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$cmd" ]]; then
      continue
    fi
    ln -sfn "$cmd" "$dest"
  done
  printf '  linked opencode commands from %s\n' "$REPO_DIR/.opencode/command"
fi

if [[ -f "$REPO_DIR/.gemini/hooks.json" ]]; then
  ln -sfn "$REPO_DIR/.gemini/hooks.json" "$HOME/.gemini/config/hooks.json"
  printf '  linked hooks.json (~/.gemini/config/hooks.json)\n'
fi

# Wire staged .mmd pre-commit validation hook into git repository hooks dir
GIT_COMMON_DIR="$(git -C "$REPO_DIR" rev-parse --git-common-dir 2>/dev/null || true)"
if [[ -n "$GIT_COMMON_DIR" && -d "$GIT_COMMON_DIR/hooks" && -x "$REPO_DIR/bin/pre-commit-mermaid.sh" ]]; then
  ln -sfn "$REPO_DIR/bin/pre-commit-mermaid.sh" "$GIT_COMMON_DIR/hooks/pre-commit"
  printf '  linked git pre-commit hook (%s/hooks/pre-commit -> bin/pre-commit-mermaid.sh)\n' "$GIT_COMMON_DIR"
fi

# ── 4. T3 Code Native Quality Engine Configuration (~/.t3/userdata/settings.json)
T3_SETTINGS="$HOME/.t3/userdata/settings.json"
if command -v python3 >/dev/null 2>&1 && [[ -d "$HOME/.t3/userdata" ]]; then
  python3 - "$T3_SETTINGS" <<'PY_EOF'
import json, os, sys, tempfile

settings_path = sys.argv[1]
data = {}
if os.path.exists(settings_path):
    try:
        with open(settings_path) as f:
            data = json.load(f)
    except Exception:
        data = {}

# 1. Branch Naming
data["branchNamingMode"] = "semantic"
data["branchNameInstructions"] = (
    "Use lowercase Conventional Branch prefixes (feat/, fix/, refactor/, docs/, test/, chore/) "
    "followed by a concise hyphenated slug under 50 characters."
)

# 2. Source Control Writing Style
data["sourceControlWritingStyle"] = {
    "mode": "custom",
    "customInstructions": (
        "Use Conventional Commits (feat:, fix:, refactor:, docs:, test:, chore:) with a subject line under 70 characters. "
        "In PR descriptions, include: (1) Executive Intent & Return Contract, "
        "(2) Numbered Block-by-Block Walkthrough with monospace Condition -> Action truth tables and a compact Unicode control-flow tree (├─ / └─), "
        "(3) mermaid-lens Architectural Delta Diagram (fenced mermaid block, <=12 nodes, <=3 subgraphs, alphanumeric IDs with double-quoted labels and [NEW]/[MODIFIED] tags) when the PR mutates cross-boundary I/O, state machines, complex DAGs, or 3+ entity schemas, "
        "(4) Important Limits & Ponytail shortcuts (shortcut: <limit>, <when to upgrade>), and "
        "(5) Verification & Test Plan. Format all file and symbol references as clickable [name](file:///absolute/path) links. "
        "Never use raw LaTeX math delimiters ($$ or $...$)."
    ),
    "followChangeRequestTemplates": True
}

# 3. Review Guides
data["reviewGuidesEnabled"] = True
data["reviewGuideInstructions"] = (
    "Structure every Review Guide using the High-Signal Walkthrough, Ponytail & mermaid-lens Standard: "
    "(1) Executive Intent & Return Contract (1-2 sentences + bulleted outcomes), "
    "(2) Order review groups from highest architectural/behavioral risk to boilerplate, "
    "(3) Include a monospace Condition -> Action table, compact Unicode control-flow tree (├─ / └─), and an inline mermaid-lens delta diagram (<=12 nodes, <=3 subgraphs, double-quoted labels, [NEW]/[MODIFIED] prefixes) whenever cross-boundary I/O, state machines, or DAGs are modified, "
    "(4) Audit for Ponytail compliance (flag unnecessary abstractions, dead code, missing Tier-1 boundary docblocks or Tier-2 numbered step comments, or unannotated shortcuts), and "
    "(5) Use clickable [name](file:///absolute/path#L10-L20) links and fenced mermaid diagrams with quoted labels (no raw LaTeX math)."
)

# 4. Default Project Scripts (Toolbar Actions)
existing_scripts = data.get("defaultProjectScripts", [])
custom_scripts = [
    {
        "id": "sync-agent-configs",
        "name": "Sync & Link Providers",
        "command": "/Users/alex/Github/ne1cc/terminal-configs/bin/link-agent-skills.sh",
        "icon": "configure",
        "runOnWorktreeCreate": True,
        "runOnSettle": False,
        "async": True
    },
    {
        "id": "ponytail-debt-ledger",
        "name": "Ponytail Debt",
        "command": "rg -n 'shortcut:|ponytail:' . || echo 'Zero Ponytail shortcuts or deferred debt found.'",
        "icon": "lint",
        "runOnWorktreeCreate": False,
        "runOnSettle": False,
        "async": False
    },
    {
        "id": "compile-mermaid-diagrams",
        "name": "Compile Diagrams",
        "command": "/Users/alex/Github/ne1cc/terminal-configs/bin/compile-mermaid.sh",
        "icon": "build",
        "runOnWorktreeCreate": False,
        "runOnSettle": False,
        "async": False
    },
    {
        "id": "verify-agent-configs",
        "name": "Verify Configs & Links",
        "command": "/Users/alex/Github/ne1cc/terminal-configs/bin/link-agent-skills.sh --verify",
        "icon": "test",
        "runOnWorktreeCreate": False,
        "runOnSettle": False,
        "async": False
    }
]

# Merge by id, keeping custom scripts up to date while preserving others
merged_scripts = []
custom_ids = {s["id"] for s in custom_scripts}
for s in existing_scripts:
    if s.get("id") not in custom_ids:
        merged_scripts.append(s)
merged_scripts.extend(custom_scripts)
data["defaultProjectScripts"] = merged_scripts

# Atomic write using temp file rename
dir_name = os.path.dirname(settings_path)
os.makedirs(dir_name, exist_ok=True)
with tempfile.NamedTemporaryFile("w", dir=dir_name, delete=False) as tf:
    json.dump(data, tf, indent=2)
    tf.write("\n")
    temp_path = tf.name

os.replace(temp_path, settings_path)
print("  configured T3 Code native quality engine and toolbar scripts in ~/.t3/userdata/settings.json")
PY_EOF
fi

# ── 5. Claude Code Settings Permissions ──────────────────────────────────────
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
PY_EOF
fi

# ── 6. Ponytail Package & Plugins Installation ──────────────────────────────
if [[ -x "$REPO_DIR/bin/install-ponytail.sh" ]]; then
  "$REPO_DIR/bin/install-ponytail.sh"
fi

# ── 7. Integrity Verification ────────────────────────────────────────────────
verify_configs
printf 'Done linking agent skills.\n'
