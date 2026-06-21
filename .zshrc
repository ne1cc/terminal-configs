# ==============================================================================
# 1. POWERLEVEL10K INSTANT PROMPT
# ==============================================================================
# Must be first — before any output or prompts.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# 2. OH MY ZSH INITIALIZATION & CONFIGURATION
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"

# Powerlevel10k — OMZ loads this from custom/themes/powerlevel10k/
ZSH_THEME="powerlevel10k/powerlevel10k"

# Disable auto-setting terminal title (tmux owns this)
DISABLE_AUTO_TITLE="true"

plugins=(git)

[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ==============================================================================
# 3. NVM (Node Version Manager)
# ==============================================================================
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]]          && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# ==============================================================================
# 4. POWERLEVEL10K CONFIG
# ==============================================================================
# OMZ loads the theme via ZSH_THEME above. This just loads your p10k settings.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ==============================================================================
# 5. ENVIRONMENT & PATH
# ==============================================================================

# Alacritty: export TERM so inner tools (nvim, tmux) know the outer terminal
export TERM="${TERM:-xterm-256color}"

# Linuxbrew / Homebrew
[[ -d "/home/linuxbrew/.linuxbrew" ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# User-local bin
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/bin" ]]        && export PATH="$HOME/bin:$PATH"

# ==============================================================================
# 6. TMUX UTILITIES
# ==============================================================================

# Prevent Zsh themes from hijacking tmux pane/window titles
case "$TERM" in
    screen*|tmux*)
        DISABLE_AUTO_TITLE="true"
        ;;
esac

# Programmatic pane title setter — call as: rename-pane "my title"
rename-pane() {
    printf "\033]2;%s\033\\" "$1"
}

# Auto-attach or create a persistent 'main' tmux session when launching
# Alacritty directly (mirrors Ghostty's command = tmux new-session -A -s main).
# Uncomment to enable:
# if [[ -z "$TMUX" ]] && command -v tmux >/dev/null; then
#     exec tmux new-session -A -s main
# fi

# ==============================================================================
# 7. CLIPBOARD COMPATIBILITY (Linux xclip / macOS pbcopy shim)
# ==============================================================================

# Provide pbcopy / pbpaste on Linux so macOS-era scripts still work
if [[ "$OSTYPE" != darwin* ]]; then
    if command -v xclip >/dev/null; then
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    elif command -v xsel >/dev/null; then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    fi
fi

# ==============================================================================
# 8. REFACTORED ANTIGRAVITY AUDIT ENGINE WITH AUTOMATED POST-HOOKS
# ==============================================================================
antigravity_audit() {
    local log_file="$HOME/.gemini_history.md"
    local start_time=$(date +%s)
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "Not a git repo")

    local tmp_prompt=$(mktemp)
    local tmp_output=$(mktemp)
    local tmp_session=$(mktemp)

    if [ "$current_branch" != "Not a git repo" ]; then
        if ! git diff --quiet; then
            echo -e "\033[31m[!] Error: Working directory has unstaged changes. Commit or stash them first.\033[0m"
            rm -f "$tmp_prompt" "$tmp_output" "$tmp_session"
            return 1
        fi
    fi

    if [ $# -gt 0 ]; then
        echo "$*" > "$tmp_prompt"
    else
        echo -e "\033[33m[*] No inline prompt detected. Type your prompt below and press Ctrl+D when finished:\033[0m"
        cat > "$tmp_prompt"
    fi

    echo -e "\033[32m[*] Forwarding to Antigravity CLI and streaming tokens...\033[0m"
    antigravity < "$tmp_prompt" | tee "$tmp_output"

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    {
        echo "---"
        echo "## [Antigravity Session] - $timestamp"
        echo "**Context:** Run on branch \`$current_branch\` | Directory: \`$PWD\` | Duration: \`${duration}s\`"

        if [ "$current_branch" != "Not a git repo" ]; then
            local last_commit=$(git log -n 1 --format="%h - %s (%an, %ar)" 2>/dev/null)
            echo "**Base Commit:** \`$last_commit\`"
        fi
        echo ""
        echo "### Ingested Prompt"
        echo "\`\`\`text"
        cat "$tmp_prompt"
        echo "\`\`\`"
        echo ""
        echo "### Raw CLI Stdout Output"
        echo "\`\`\`markdown"
        cat "$tmp_output"
        echo "\`\`\`"
        echo ""

        if [ "$current_branch" != "Not a git repo" ]; then
            echo "### Modified Files"
            local mod_files=$(git diff --name-only)
            if [ -n "$mod_files" ]; then
                echo "\`\`\`text"
                echo "$mod_files"
                echo "\`\`\`"
            else
                echo "_No files modified._"
            fi
            echo ""
            echo "### Code Mutations & Line-by-Line Diffs"
            local git_diff=$(git diff --unified=3)
            if [ -n "$git_diff" ]; then
                echo "\`\`\`diff"
                echo "$git_diff"
                echo "\`\`\`"
            else
                echo "_No file-system changes detected during this session._"
            fi
        fi
        echo ""
    } > "$tmp_session"

    cat "$tmp_session" >> "$log_file"

    echo -e "\033[32m[*] Launching automated visual diff review (Press 'q' to close)...\033[0m"
    cat "$tmp_session" | delta --side-by-side --syntax-theme="Nord"

    rm -f "$tmp_prompt" "$tmp_output" "$tmp_session"
}

# Export and preview the current AI chat session audit report by date
agya() {
    local BRAIN_DIR="$HOME/.gemini/antigravity-cli/brain"
    local AUDIT_DEST_ROOT="$HOME/Desktop/Audits"

    if [[ ! -d "$BRAIN_DIR" ]]; then
        echo "Error: Antigravity brain directory not found at: $BRAIN_DIR"
        return 1
    fi

    local LATEST_SESSION_DIR=""
    local AUDIT_FILE=""
    for dir in $BRAIN_DIR/*(N/om); do
        local md_files=("$dir"/*.md(N))
        if [[ ${#md_files[@]} -gt 0 ]]; then
            LATEST_SESSION_DIR="$dir"
            AUDIT_FILE="${md_files[1]}"
            break
        fi
    done

    if [[ -z "$LATEST_SESSION_DIR" || -z "$AUDIT_FILE" ]]; then
        echo "Error: No session folder containing a markdown report found in: $BRAIN_DIR"
        return 1
    fi

    local AUDIT_FILENAME=$(basename "$AUDIT_FILE")
    local DATE_FOLDER="${AUDIT_DEST_ROOT}/$(date +%Y-%m-%d)"
    mkdir -p "$DATE_FOLDER"
    local TARGET_FILE="${DATE_FOLDER}/${AUDIT_FILENAME}"

    cp "$AUDIT_FILE" "$TARGET_FILE"
    echo "Exported: $TARGET_FILE"

    if command -v delta >/dev/null; then
        cat "$TARGET_FILE" | delta --side-by-side --syntax-theme="Nord"
    fi

    # Open in viewer: xdg-open on Linux, One Markdown on macOS
    if [[ "$OSTYPE" == darwin* ]] && command -v open >/dev/null; then
        open -a "One Markdown" "$TARGET_FILE" 2>/dev/null || open "$TARGET_FILE"
    elif command -v glow >/dev/null; then
        glow -p "$TARGET_FILE"
    elif command -v xdg-open >/dev/null; then
        xdg-open "$TARGET_FILE" &>/dev/null &
    fi
}

# ==============================================================================
# 9. SCREENSHOT UTILITY (Linux + macOS)
# ==============================================================================
unalias snap 2>/dev/null
snap() {
    local dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    local filepath="$dir/Screenshot_$(date +%Y%m%d_%H%M%S).png"

    if [[ "$OSTYPE" == darwin* ]]; then
        screencapture "$filepath"
        if [[ -f "$filepath" ]]; then
            osascript -e "set the clipboard to (read (POSIX file \"$filepath\") as «class PNGf»)"
            echo "Captured: $filepath (copied to clipboard)"
        fi
    elif command -v gnome-screenshot >/dev/null; then
        gnome-screenshot -f "$filepath" && xclip -selection clipboard -t image/png < "$filepath"
        echo "Captured: $filepath (copied to clipboard)"
    elif command -v scrot >/dev/null; then
        scrot "$filepath" && xclip -selection clipboard -t image/png < "$filepath"
        echo "Captured: $filepath (copied to clipboard)"
    else
        echo "No screenshot tool found. Install gnome-screenshot or scrot."
    fi
}

# ==============================================================================
# 10. ALIASES
# ==============================================================================

# Antigravity / audit ledger
alias glog='glow -p ~/.gemini_history.md'
alias gdiff='cat ~/.gemini_history.md | delta --side-by-side --syntax-theme="Nord"'

# Git shortcuts
alias gis='git rev-parse --is-inside-work-tree'
alias gc='git clone'

# Alacritty — quick config reload (live-reload is automatic, but this forces a check)
alias alacritty-config='${EDITOR:-nvim} ~/.config/alacritty/alacritty.toml'

# tmux shortcuts
alias ta='tmux attach -t main || tmux new-session -s main'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'

# ==============================================================================
# 11. GIT POST-COMMIT AUDIT HOOK INSTALLER
# ==============================================================================
agyih() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Error: Not inside a Git repository."
        return 1
    fi

    local hook_file=".git/hooks/post-commit"

    cat << 'EOF' > "$hook_file"
#!/usr/bin/env zsh
log_file="$HOME/.gemini_history.md"
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
commit_hash=$(git log -1 --pretty=%h 2>/dev/null)
commit_msg=$(git log -1 --pretty=%B 2>/dev/null)
mod_files=$(git diff --name-only HEAD~1 HEAD 2>/dev/null)
git_diff=$(git diff --unified=3 HEAD~1 HEAD 2>/dev/null)

{
    echo "---"
    echo "## [Git Commit Log] - $timestamp"
    echo "**Context:** Commit \`$commit_hash\` on branch \`$current_branch\` | Directory: \`$PWD\`"
    echo "**Message:** $commit_msg"
    echo ""
    echo "### Modified Files"
    echo "\`\`\`text"
    echo "$mod_files"
    echo "\`\`\`"
    echo ""
    echo "### Code Mutations & Line-by-Line Diffs"
    if [[ -n "$git_diff" ]]; then
        echo "\`\`\`diff"
        echo "$git_diff"
        echo "\`\`\`"
    else
        echo "_No file changes._"
    fi
    echo ""
} >> "$log_file"

echo -e "\033[32m[*] Logged commit $commit_hash to ~/.gemini_history.md\033[0m"
EOF

    chmod +x "$hook_file"
    echo "Installed post-commit hook at: $hook_file"
}
# Enable vi command line editing mode
bindkey -v

# Map standard vim movements inside history search
bindkey '^K' up-line-or-history
bindkey '^J' down-line-or-history

# ==============================================================================
# GIT WORKTREE + CLAUDE SESSION WORKFLOW
# ==============================================================================
# wt-new <branch> [base]  — create worktree sibling dir, cd into it, launch claude
wt-new() {
  local branch=$1 base=${2:-HEAD}
  [[ -z "$branch" ]] && { echo "Usage: wt-new <branch> [base]"; return 1 }
  local root; root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not in a git repo"; return 1 }
  local dir="${root%/*}/${branch}"
  git worktree add -b "$branch" "$dir" "$base" || return 1
  cd "$(realpath "$dir")" && claude --name "$branch"
}

# wt-tmux-attach — fzf-pick an existing worktree, open in a new tmux window with claude
wt-tmux-attach() {
  local row; row=$(git worktree list 2>/dev/null | tail -n +2 \
    | fzf --height=50% --reverse --prompt="worktree> ") || return 0
  local dir; dir=$(awk '{print $1}' <<< "$row")
  local name; name=$(basename "$dir")
  tmux new-window -c "$dir" -n "$name" "zsh -ic 'claude --name $name; exec zsh'"
}

# wt-rm [branch] — remove a worktree (fzf picker if no arg)
wt-rm() {
  local branch=${1:-$(git worktree list 2>/dev/null | tail -n +2 \
    | fzf --height=50% --reverse --prompt="remove> " | awk '{print $NF}' | tr -d '[]')}
  [[ -z "$branch" ]] && return 0
  local dir; dir=$(git worktree list | awk -v b="[$branch]" '$NF==b {print $1}')
  git worktree remove --force "$dir" && git branch -d "$branch"
}

# ==============================================================================
# CLAUDE CODE 10X DEVELOPER EXTENSIONS
# ==============================================================================

# cco: Standard Claude Code wrapper to pass arguments
cco() {
  claude "$@"
}

# cinit: Generate a starter CLAUDE.md file
cinit() {
  if [[ -f CLAUDE.md ]]; then
    echo "CLAUDE.md already exists."
    return 0
  fi
  cat << 'EOF' > CLAUDE.md
# CLAUDE.md

## Build and Test Commands
- Build: `npm run build` or equivalent
- Test: `npm test` or equivalent

## Style Guidelines
- Maintain consistent code style and formatting.
- Keep lines concise and documented.
EOF
  echo "✓ Created starter CLAUDE.md"
}

# cbug: Send the current clipboard contents (e.g. error/stacktrace) to Claude to debug
cbug() {
  local clipboard=""
  if [[ "$OSTYPE" == darwin* ]]; then
    clipboard=$(pbpaste)
  elif command -v xclip >/dev/null; then
    clipboard=$(xclip -selection clipboard -o)
  elif command -v xsel >/dev/null; then
    clipboard=$(xsel --clipboard --output)
  fi

  if [[ -z "$clipboard" ]]; then
    echo "Clipboard is empty."
    return 1
  fi

  echo "Sending clipboard to Claude for debugging..."
  claude -p "I am encountering this error/issue. Please diagnose and provide a solution:
$clipboard"
}

# creview: Ask Claude to review unstaged or staged git changes
creview() {
  local diff
  diff=$(git diff)
  if [[ -z "$diff" ]]; then
    diff=$(git diff --cached)
  fi
  if [[ -z "$diff" ]]; then
    echo "No unstaged or staged changes to review."
    return 0
  fi
  echo "Reviewing changes with Claude..."
  claude -p "Please review these git changes. Identify potential bugs, edge cases, style issues, or optimizations:
$diff"
}

# cplan: Ask Claude to create a detailed implementation plan for a task
cplan() {
  if [[ -z "$*" ]]; then
    echo "Usage: cplan <task description>"
    return 1
  fi
  claude -p "Please create a detailed step-by-step implementation plan for the following task: $*"
}

# cdoc: Ask Claude to document a file
cdoc() {
  if [[ -z "$1" ]]; then
    echo "Usage: cdoc <filename>"
    return 1
  fi
  if [[ ! -f "$1" ]]; then
    echo "File not found: $1"
    return 1
  fi
  echo "Generating documentation for $1..."
  claude -p "Please write high-quality documentation, comments, and docstrings for this file:
$(cat "$1")"
}

# ctest: Ask Claude to write tests for a file
ctest() {
  if [[ -z "$1" ]]; then
    echo "Usage: ctest <filename>"
    return 1
  fi
  if [[ ! -f "$1" ]]; then
    echo "File not found: $1"
    return 1
  fi
  echo "Generating unit tests for $1..."
  claude -p "Please write comprehensive unit tests for this file:
$(cat "$1")"
}

# cgc: Generate a conventional commit message from git diff and commit
cgc() {
  local diff
  diff=$(git diff --cached)
  if [[ -z "$diff" ]]; then
    diff=$(git diff)
  fi
  if [[ -z "$diff" ]]; then
    echo "No changes to commit."
    return 0
  fi
  echo "Analyzing diff and generating commit message..."
  local msg
  msg=$(claude -p "Generate a short, concise conventional commit message for the following diff. Output ONLY the commit message itself, nothing else:
$diff")
  
  if [[ -n "$msg" ]]; then
    echo -e "\nProposed commit message:\n$msg\n"
    echo -n "Commit with this message? [y/N] "
    read -r -k 1 reply
    echo ""
    if [[ "$reply" =~ ^[Yy]$ ]]; then
      git commit -m "$msg"
    fi
  else
    echo "Failed to generate commit message."
  fi
}

# ==============================================================================
# MODERN DEV TOOLS & FUZZY WORKFLOWS
# ==============================================================================

# Zoxide (Smart cd) Hook
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi

# Direnv Hook
if command -v direnv >/dev/null; then
  eval "$(direnv hook zsh)"
fi

# FZF Shell Integration & Patched Command Defaults
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
  if command -v fd >/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi

# Modern CLI Replacements Aliases
if command -v eza >/dev/null; then
  alias ls='eza --icons --git-repos-detail --group-directories-first'
  alias ll='eza -l --icons --git-repos-detail --group-directories-first'
  alias la='eza -la --icons --git-repos-detail --group-directories-first'
  alias tree='eza --tree --icons'
fi

if command -v bat >/dev/null; then
  alias cat='bat --style=header,grid,snip --theme=ansi'
fi

# gb: Interactive Git Branch Switcher with Log Preview
unalias gb 2>/dev/null
gb() {
  local branch
  branch=$(git branch --color=always | fzf --ansi --no-multi --preview-window right:65% --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%h %ad %s" {1}') &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# gshow: Interactive Git Commit History Diff Browser
gshow() {
  git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --preview 'f(v)={ set -- $(echo "$v" | grep -o "[a-f0-9]\{7,\}"); [ $# -eq 0 ] || git show --color=always "$1"; }; f {}' \
      --header "Enter to view commit details" \
      --bind "enter:execute(git show --color=always {1} | less -R)"
}
