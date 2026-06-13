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
