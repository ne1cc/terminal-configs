# ==============================================================================
# 1. POWERLEVEL10K INSTANT PROMPT
# ==============================================================================
# Must be first — before any output or prompts.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Detect WL (Windows Subsystem for Linux)
if grep -qi microsoft /proc/version 2>/dev/null; then
    export IS_WSL=1
fi

# Locale sanitization (fixes macOS ICU format warnings in bash / tools)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Starship Prompt Initialization (fallback/alternative)
if command -v starship >/dev/null 2>&1 && [[ "$ZSH_THEME" != "powerlevel10k/powerlevel10k" ]]; then
    eval "$(starship init zsh)"
fi

# ==============================================================================
# 5. ENVIRONMENT & PATH
# ==============================================================================

# Default Editor: Neovim
export EDITOR="nvim"
export VISUAL="nvim"

# Alacritty: export TERM so inner tools (nvim, tmux) know the outer terminal
export TERM="${TERM:-xterm-256color}"

# Homebrew — macOS (Apple Silicon / Intel) and Linux (Linuxbrew)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# User-local bin
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/bin" ]]        && export PATH="$HOME/bin:$PATH"

# Claude Code Agent Teams (Experimental Multi-Agent Orchestrator)
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1


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
if [[ -z "$TMUX" ]] && command -v tmux >/dev/null; then
    exec tmux new-session -A -s main
fi

# ==============================================================================
# 7. CLIPBOARD COMPATIBILITY (Linux xclip / macOS pbcopy shim)
# ==============================================================================

# Provide pbcopy / pbpaste on Linux so macOS-era scripts still work
if [[ "$OSTYPE" != darwin* ]]; then
    if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null 2>&1; then
        alias pbcopy='wl-copy'
        alias pbpaste='wl-paste'
    elif command -v xclip >/dev/null 2>&1; then
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    elif command -v xsel >/dev/null 2>&1; then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    elif [[ -n "${IS_WSL:-}" ]] && command -v clip.exe >/dev/null 2>&1; then
        alias pbcopy='clip.exe'
        alias pbpaste='powershell.exe -NoProfile -Command "Get-Clipboard"'
    fi
fi

# ==============================================================================
# LIGHTNING-FAST COPYLAST (0ms re-execution, captures actual terminal output)
# ==============================================================================
autoload -Uz add-zsh-hook

_copylast_preexec() {
    # Don't overwrite the last command if running copylast itself
    if [[ "$1" =~ ^[[:space:]]*copylast([[:space:]]|$) ]]; then
        _copylast_is_self=1
        return
    fi
    _copylast_is_self=0
    _copylast_cmd="$1"
    if [[ -n "$TMUX" ]]; then
        local hist=$(tmux display-message -p "#{history_size}")
        local cy=$(tmux display-message -p "#{cursor_y}")
        _copylast_start_abs=$(( hist + cy ))
        tmux set-option -p @copylast_start "$_copylast_start_abs" 2>/dev/null || true
        tmux set-option -p @copylast_cmd "$1" 2>/dev/null || true
    fi
}

_copylast_precmd() {
    if [[ "${_copylast_is_self:-0}" -eq 1 ]]; then
        _copylast_is_self=0
        return
    fi
    if [[ -n "$TMUX" && -n "$_copylast_start_abs" ]]; then
        local end_hist=$(tmux display-message -p "#{history_size}")
        local end_cy=$(tmux display-message -p "#{cursor_y}")
        _copylast_saved_start="$_copylast_start_abs"
        _copylast_saved_end=$(( end_hist + end_cy - 1 ))
        _copylast_saved_cmd="${_copylast_cmd:-$(tmux show-options -p -v @copylast_cmd 2>/dev/null)}"
        tmux set-option -p @copylast_end "$_copylast_saved_end" 2>/dev/null || true
        unset _copylast_start_abs
    fi
}

add-zsh-hook preexec _copylast_preexec
add-zsh-hook precmd _copylast_precmd

# Copy last command output (stdout + stderr) directly from terminal scrollback
copylast() {
    local raw_mode=0
    local mode=""
    for arg in "$@"; do
        case "$arg" in
            -r|--raw) raw_mode=1 ;;
            -a|--all) mode="-a" ;;
            [0-9]*) mode="$arg" ;;
            -h|--help)
                echo "Usage: copylast [-r|--raw] [-a|--all] [N]"
                echo "Copies output of previous terminal command to clipboard instantly."
                return 0
                ;;
        esac
    done

    local output=""
    local cmd="${_copylast_saved_cmd:-$(tmux show-options -p -v @copylast_cmd 2>/dev/null || true)}"

    if [[ -n "$TMUX" ]]; then
        if [[ "$mode" == "-a" ]]; then
            output=$(tmux capture-pane -p -J -S -3000)
        elif [[ "$mode" =~ ^[0-9]+$ ]]; then
            output=$(tmux capture-pane -p -J -S "-$mode")
        else
            local start_abs="${_copylast_saved_start:-$(tmux show-options -p -v @copylast_start 2>/dev/null || true)}"
            local end_abs="${_copylast_saved_end:-$(tmux show-options -p -v @copylast_end 2>/dev/null || true)}"
            local curr_hist=$(tmux display-message -p "#{history_size}")

            if [[ -n "$start_abs" && -n "$end_abs" ]]; then
                local s=$(( start_abs - curr_hist ))
                local e=$(( end_abs - curr_hist ))

                if (( s <= e )); then
                    local -a cap_args=(-p -J)
                    (( raw_mode == 1 )) && cap_args+=(-e)
                    output=$(tmux capture-pane "${cap_args[@]}" -S "$s" -E "$e")
                    output="${output%"${output##*[![:space:]]}"}"
                fi
            fi
        fi
    fi

    # Fallback when outside tmux or if hook captured nothing
    if [[ -z "$output" ]]; then
        local last_cmd
        last_cmd=$(fc -ln -1 2>/dev/null)
        if [[ -z "$last_cmd" ]]; then
            last_cmd=$(history | tail -n 1 | sed 's/^[ ]*[0-9]*[ ]*//')
        fi
        if [[ -n "$last_cmd" ]]; then
            cmd="$last_cmd"
            output=$(eval "$last_cmd" 2>&1)
        fi
    fi

    if [[ -z "$output" ]]; then
        echo "copylast: No output captured from last command ('${cmd:-unknown}')." >&2
        return 1
    fi

    # Fast clipboard copy (priority: pbcopy / wl-copy / xclip / xsel / clip.exe)
    if command -v pbcopy >/dev/null 2>&1; then
        printf "%s" "$output" | pbcopy
    elif [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null 2>&1; then
        printf "%s" "$output" | wl-copy
    elif command -v xclip >/dev/null 2>&1; then
        printf "%s" "$output" | xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        printf "%s" "$output" | xsel --clipboard --input
    elif [[ -n "${IS_WSL:-}" ]] && command -v clip.exe >/dev/null 2>&1; then
        printf "%s" "$output" | clip.exe
    fi

    # Also emit OSC 52 sequence for remote/SSH/passthrough clipboard sync
    if [[ -n "$TMUX" ]]; then
        local b64
        b64=$(printf "%s" "$output" | base64 | tr -d '\r\n')
        printf "\033Ptmux;\033\033]52;c;%s\007\033\\" "$b64" 2>/dev/null || true
    fi

    local lines=$(printf "%s\n" "$output" | wc -l | tr -d ' ')
    local bytes=$(printf "%s" "$output" | wc -c | tr -d ' ')
    echo "✓ Copied output of '${cmd}' (${lines} lines, ${bytes} bytes) to clipboard"
}


# Cross-platform 'open' command: macOS has it natively, Linux uses xdg-open, WSL uses cmd.exe
if [[ "$OSTYPE" != darwin* ]] && ! command -v open >/dev/null; then
    open() {
        if command -v xdg-open >/dev/null; then
            xdg-open "$@" &>/dev/null &
        elif [[ -n "${IS_WSL:-}" ]] && command -v cmd.exe >/dev/null; then
            cmd.exe /c start "" "$@" &>/dev/null &
        else
            echo "open: no handler found for $1" >&2
            return 1
        fi
    }
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
alias agy-yolo='agy --dangerously-skip-permissions'
alias agyy='agy --dangerously-skip-permissions'
alias yolo='agy --dangerously-skip-permissions'
alias glog='glow -p ~/.gemini_history.md'
alias gdiff='cat ~/.gemini_history.md | delta --side-by-side --syntax-theme="Nord"'

# Quick access & Application Openers
alias lg="lazygit"
alias mu="mupdf"
alias om='open -a "One Markdown"'
alias omd='open -a "One Markdown"'
alias onemarkdown='open -a "One Markdown"'
alias prev='open -a Preview'
alias preview='open -a Preview'
alias finder='open'
alias of='open -R'

# Yazi shell wrapper (changes terminal PWD on exit)
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Open lazygit for a specific repo
alias lgd="lazygit --path ~/dotfiles"

# Yazi image preview protocol for Ghostty
export YAZI_IMAGE_PROTOCOL="ghostty"

# Git shortcuts
alias gis='git rev-parse --is-inside-work-tree'
alias gc='git clone'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gl='git log --oneline --graph --decorate -n 20'
alias gaa='git add -A'

# Directory Navigation & Quick Jumps
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -p'

# Data Engineering & Quick Inspection
alias headcsv='head -n 20'
alias tailcsv='tail -n 20'
alias prettyjson='python3 -m json.tool'
alias duck='duckdb'

# Docker & Container Shortcuts
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f --tail=100'

# tmux shortcuts
alias ta='tmux attach -t main || tmux new-session -s main'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'

# Developer & Data Project Scaffolding Utilities
mkpy() {
    local proj="${1:-my_python_project}"
    mkdir -p "$proj"/{src/"$proj",tests,data/{raw,processed},notebooks,scripts}
    touch "$proj"/{README.md,.env,.gitignore,requirements.txt,src/"$proj"/__init__.py,src/"$proj"/main.py,tests/__init__.py}
    echo -e "python-version = \"3.11\"\n__pycache__/\n*.pyc\n.env\n.venv/\ndata/\n.pytest_cache/\n.ipynb_checkpoints/" > "$proj/.gitignore"
    echo -e "# $proj\n\nGenerated Python/Data engineering project repository." > "$proj/README.md"
    echo "print('Project $proj initialized successfully!')" > "$proj/src/$proj/main.py"
    (cd "$proj" && git init >/dev/null 2>&1 && echo "✓ Initialized git repo in $proj")
    echo "✓ Created Python project scaffold: $proj/"
}

mkts() {
    local proj="${1:-my_ts_project}"
    mkdir -p "$proj"/{src,tests,dist}
    touch "$proj"/{README.md,.env,.gitignore,src/index.ts}
    echo -e "node_modules/\ndist/\n.env\n*.log" > "$proj/.gitignore"
    echo -e "# $proj\n\nGenerated TypeScript project repository." > "$proj/README.md"
    echo "console.log('Project $proj initialized successfully!');" > "$proj/src/index.ts"
    (cd "$proj" && git init >/dev/null 2>&1 && echo "✓ Initialized git repo in $proj")
    echo "✓ Created TypeScript project scaffold: $proj/"
}

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
if command -v fzf >/dev/null 2>&1; then
  # Source fzf completion & key bindings (Homebrew & standard paths supported)
  if [[ -d "/opt/homebrew/opt/fzf/shell" ]]; then
    source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2>/dev/null
    source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" 2>/dev/null
  elif [[ -d "/usr/local/opt/fzf/shell" ]]; then
    source "/usr/local/opt/fzf/shell/completion.zsh" 2>/dev/null
    source "/usr/local/opt/fzf/shell/key-bindings.zsh" 2>/dev/null
  else
    source <(fzf --zsh) 2>/dev/null
  fi

  # Explicitly bind fzf widgets for vi mode & default keymaps
  if zle -l fzf-history-widget 2>/dev/null; then
    bindkey '^R' fzf-history-widget
    bindkey -M viins '^R' fzf-history-widget
    bindkey -M vicmd '^R' fzf-history-widget
  fi
  if zle -l fzf-file-widget 2>/dev/null; then
    bindkey '^T' fzf-file-widget
    bindkey -M viins '^T' fzf-file-widget
    bindkey -M vicmd '^T' fzf-file-widget
  fi
  if zle -l fzf-cd-widget 2>/dev/null; then
    bindkey '\ec' fzf-cd-widget
    bindkey -M viins '\ec' fzf-cd-widget
    bindkey -M vicmd '\ec' fzf-cd-widget
  fi

  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'

    # Use fd inside the ** completion popup
    _fzf_compgen_path() {
      fd --hidden --follow --exclude ".git" . "$1"
    }

    _fzf_compgen_dir() {
      fd --type d --hidden --follow --exclude ".git" . "$1"
    }
  fi
fi

# Modern CLI Replacements Aliases
alias venv='uv venv && source .venv/bin/activate'

if command -v eza >/dev/null; then
  alias l='eza -la --icons --group-directories-first'
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias tree='eza --tree --icons'
else
  alias l='ls -lah'
fi

# Taskwarrior Ergonomic Aliases
if command -v task >/dev/null; then
  alias t='task'
  alias ta='task add'
  alias tl='task list'
  alias tn='task next'
  alias tui='taskwarrior-tui'
  alias tdev='task project:dev list'
fi

if command -v bat >/dev/null; then
  alias cat='bat --style=header,grid,snip --theme=ansi'
fi

if command -v duf >/dev/null; then
  alias df='duf'
fi

if command -v dust >/dev/null; then
  alias du='dust'
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
[[ -d "/usr/local/mysql/bin" ]] && export PATH="/usr/local/mysql/bin:$PATH"

# ==============================================================================
# 12. 10X DEVELOPER WORKFLOW UTILITIES
# ==============================================================================

# --- Git Power Moves ---
alias groot='cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"'
alias gundo='git reset --soft HEAD~1'
alias gwip='git add -A && git commit -m "wip: save point [skip ci]" --no-verify'
alias gunwip='git log -n 1 --pretty=%B 2>/dev/null | grep -q "wip: save point" && git reset HEAD~1'
alias gpristine='git reset --hard && git clean -dfx'
alias gignored='git status --ignored -s | grep "^!!"'
alias gauthors='git shortlog -sn --no-merges'

# --- Fast Clipboard Ergonomics ---
alias cbranch='git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d "\n" | pbcopy && echo "✓ Copied branch: $(pbpaste)"'
alias csha='git rev-parse --short HEAD 2>/dev/null | tr -d "\n" | pbcopy && echo "✓ Copied SHA: $(pbpaste)"'

cpath() {
  local p="${1:-$PWD}"
  local abs_path
  abs_path=$(realpath "$p" 2>/dev/null || echo "$p")
  printf "%s" "$abs_path" | pbcopy
  echo "✓ Copied path: $abs_path"
}

cpfile() {
  if [[ -f "$1" ]]; then
    cat "$1" | pbcopy
    local lines
    lines=$(wc -l < "$1" | tr -d ' ')
    echo "✓ Copied contents of $1 ($lines lines) to clipboard"
  else
    echo "Error: File not found: $1"
    return 1
  fi
}

# --- Ports, Networking & Local Development ---
port() {
  if [[ -z "$1" ]]; then
    echo "Usage: port <port_number>"
    return 1
  fi
  lsof -iTCP:"$1" -sTCP:LISTEN -n -P
}

killport() {
  if [[ -z "$1" ]]; then
    echo "Usage: killport <port_number>"
    return 1
  fi
  local pid
  pid=$(lsof -tiTCP:"$1" -sTCP:LISTEN)
  if [[ -n "$pid" ]]; then
    echo "$pid" | xargs kill -9
    echo "✓ Killed process(es) $pid on port $1"
  else
    echo "No listening process found on port $1"
  fi
}

serve() {
  local p="${1:-8000}"
  echo "Serving $PWD at http://localhost:$p"
  python3 -m http.server "$p"
}

alias myip='curl -s https://ipinfo.io/json'

cheat() {
  if [[ -z "$1" ]]; then
    echo "Usage: cheat <topic>"
    return 1
  fi
  curl -s "https://cheat.sh/$1"
}

# --- Interactive FZF Superpowers ---
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m --header='[Kill Process: TAB to multi-select, ENTER to kill]' --preview 'echo {}' | awk '{print $2}')
  if [[ -n "$pid" ]]; then
    echo "$pid" | xargs kill -${1:-9}
    echo "✓ Killed PID(s): $pid"
  fi
}

fo() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {}')
  [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

fenv() {
  env | sort | fzf --header='[Environment Variables]'
}

fdocker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker command not found" >&2
    return 1
  fi
  local cid
  cid=$(docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}" 2>/dev/null | \
    fzf --header-lines=1 --reverse --header="[Select Docker Container to Exec]" | awk '{print $1}')
  if [[ -n "$cid" ]]; then
    echo "Attaching to container $cid..."
    docker exec -it "$cid" /bin/sh -c "[ -e /bin/bash ] && exec /bin/bash || exec /bin/sh"
  fi
}

fssh() {
  local host
  host=$(awk '/^Host / && !/\*/ {print $2}' ~/.ssh/config 2>/dev/null | fzf --reverse --header="[Select SSH Host]")
  if [[ -n "$host" ]]; then
    if [[ -n "$TMUX" ]]; then
      tmux new-window -n "ssh:$host" "ssh $host"
    else
      ssh "$host"
    fi
  fi
}

handoff() {
  "$HOME/bin/session-handoff" "$@"
}

matrix() {
  "$HOME/bin/tmux-agent-matrix" "${1:-2}" "${2:-claude}"
}

gb-clean() {
  local default_branch
  default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  default_branch="${default_branch:-main}"
  echo "Pruning branches merged into $default_branch..."
  git checkout "$default_branch" 2>/dev/null && git pull --ff-only 2>/dev/null
  git branch --merged "$default_branch" | grep -v "^\*\|master\|main\|dev" | xargs -n 1 git branch -d 2>/dev/null || true
  echo "✓ Local merged branches cleaned."
}

# --- Smart Shell Ergonomics ---
mcd() {
  mkdir -p "$1" && cd "$1"
}

alias path='echo -e ${PATH//:/\\n}'

extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <archive_file>"
    return 1
  fi
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *.tar.xz)    tar xf "$1"      ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "Error: '$1' is not a valid file"
    return 1
  fi
}

# ==============================================================================
# KEYBINDINGS
# ==============================================================================
# Map standard emacs/vi shortcuts
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# Map Alt+K to clear line after cursor (kill-line)
bindkey '\ek' kill-line
bindkey '^[k' kill-line
bindkey -M viins '\ek' kill-line
bindkey -M vicmd '\ek' kill-line

# Remove Ctrl+K from kill-line (used for history navigation in vi mode)
bindkey -r '^K'
bindkey '^K' up-line-or-history
bindkey -M viins '^K' up-line-or-history
bindkey -M vicmd '^K' up-line-or-history

export PATH="$(npm prefix -g)/bin:$PATH"
export PATH="$HOME/.claude/bin:$PATH"
export PATH="$HOME/.nvm/versions/node/v24.16.0/bin:$PATH"
