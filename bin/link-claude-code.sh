#!/usr/bin/env bash
# link-claude-code.sh — symlink global Claude Code config and slash commands.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_CMD_DIR="$CLAUDE_DIR/commands"

printf '==> Linking Claude Code global configuration\n'

mkdir -p "$CLAUDE_CMD_DIR"

global_claude_dest="$CLAUDE_DIR/CLAUDE.md"
if [[ -f "$global_claude_dest" && ! -L "$global_claude_dest" ]]; then
  backup="$global_claude_dest.backup_$(date +%Y%m%d_%H%M%S)"
  mv "$global_claude_dest" "$backup"
  printf '  backed up existing CLAUDE.md to %s\n' "$backup"
fi

ln -sfn "$REPO_DIR/claude-code/CLAUDE.md" "$global_claude_dest"
printf '  linked: %s\n' "$global_claude_dest"

for cmd in "$REPO_DIR/claude-code/commands"/*.md; do
  [[ -f "$cmd" ]] || continue
  cmd_name="$(basename "$cmd")"
  [[ "$cmd_name" != "README.md" ]] || continue

  dest="$CLAUDE_CMD_DIR/$cmd_name"
  if [[ -f "$dest" && ! -L "$dest" ]]; then
    backup="$dest.backup_$(date +%Y%m%d_%H%M%S)"
    mv "$dest" "$backup"
    printf '  backed up existing command %s to %s\n' "$cmd_name" "$backup"
  fi

  ln -sfn "$cmd" "$dest"
  printf '  linked: %s\n' "$dest"
done

printf 'Done linking Claude Code configuration.\n'
