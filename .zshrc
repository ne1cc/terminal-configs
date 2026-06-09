# ==============================================================================
# 1. POWERLEVEL10K INSTANT PROMPT
# ==============================================================================
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# 2. OH MY ZSH INITIALIZATION & CONFIGURATION
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"

# Note: P10k overrides ZSH_THEME, but keeping it set prevents OMZ warnings
ZSH_THEME="robbyrussell"

# Disable auto-setting terminal title globally
DISABLE_AUTO_TITLE="true"

# Active plugins array
plugins=(git)

# Source Oh My Zsh engine
source $ZSH/oh-my-zsh.sh

# Source Powerlevel10k theme engine explicitly
source ~/Applications/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ==============================================================================
# 3. ENVIRONMENT & MULTIPLEXER (TMUX) UTILITIES
# ==============================================================================
# Prevent Zsh themes from hijacking tmux pane/window titles
case "$TERM" in
    screen*|tmux*)
        DISABLE_AUTO_TITLE="true"
        ;;
esac

# Explicit programmatic pane naming utility
rename-pane() {
    printf "\033]2;%s\033\\" "$1"
}

# ==============================================================================
# 4. REFACTORED ANTIGRAVITY AUDIT ENGINE WITH AUTOMATED POST-HOOKS
# ==============================================================================
antigravity_audit() {
    local log_file="$HOME/.gemini_history.md"
    local start_time=$(date +%s)
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "Not a git repo")
    
    local tmp_prompt=$(mktemp)
    local tmp_output=$(mktemp)
    local tmp_session=$(mktemp) # Temporary buffer isolating the active session block

    # 1. State Guarding: Prevent false-positive tracking data
    if [ "$current_branch" != "Not a git repo" ]; then
        if ! git diff --quiet; then
            echo -e "\033[31m[!] Error: Working directory has unstaged changes. Commit or stash them first.\033[0m"
            rm -f "$tmp_prompt" "$tmp_output" "$tmp_session"
            return 1
        fi
    fi

    # 2. Ingest Input (Handles direct arguments or interactive multi-line blocks)
    if [ $# -gt 0 ]; then
        echo "$*" > "$tmp_prompt"
    else
        echo -e "\033[33m[*] No inline prompt detected. Type your prompt below and press Ctrl+D when finished:\033[0m"
        cat > "$tmp_prompt"
    fi

    echo -e "\033[32m[*] Forwarding to Antigravity CLI and streaming tokens...\033[0m"
    
    # Target execution block adjusted for the antigravity core runtime layer
    antigravity < "$tmp_prompt" | tee "$tmp_output"

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # 3. Structural Log Generation (Compiled into a single localized buffer)
    {
        echo "---"
        echo "## [Antigravity Session] - $timestamp"
        echo "**Context:** Run on branch \`$current_branch\` | Directory: \`$PWD\` | Duration: \`${duration}s\`"
        
        if [ "$current_branch" != "Not a git repo" ]; then
            local last_commit=$(git log -n 1 --format="%h - %s (%an, %ar)" 2>/dev/null)
            echo "**Base Commit:** \`$last_commit\`"
        fi
        echo ""
        echo "### 📥 Ingested Prompt"
        echo "\`\`\`text"
        cat "$tmp_prompt"
        echo "\`\`\`"
        echo ""
        echo "### 📤 Raw CLI Stdout Output"
        echo "\`\`\`markdown"
        cat "$tmp_output"
        echo "\`\`\`"
        echo ""
        
        if [ "$current_branch" != "Not a git repo" ]; then
            echo "### 📂 Modified Files"
            local mod_files=$(git diff --name-only)
            if [ -n "$mod_files" ]; then
                echo "\`\`\`text"
                echo "$mod_files"
                echo "\`\`\`"
            else
                echo "_No files modified._"
            fi
            echo ""

            echo "### 🛠️ Code Mutations & Line-by-Line Diffs"
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

    # 4. Atomic append commit to the permanent master audit ledger
    cat "$tmp_session" >> "$log_file"

    # 5. AUTOMATED POST-HOOK HANDOFF: Launch delta instantly for side-by-side verification
    echo -e "\033[32m[*] Launching automated visual diff review (Press 'q' to close)...\033[0m"
    cat "$tmp_session" | delta --side-by-side --syntax-theme="Nord"

    # 6. Clean up file allocation maps safely
    rm -f "$tmp_prompt" "$tmp_output" "$tmp_session"
}

# Export and preview the current AI chat session audit report by date
agya() {
    local BRAIN_DIR="$HOME/.gemini/antigravity-cli/brain"
    local AUDIT_DEST_ROOT="$HOME/Desktop/Audits"

    # 1. Verify brain directory exists
    if [[ ! -d "$BRAIN_DIR" ]]; then
        echo "❌ Error: Antigravity brain directory not found at: $BRAIN_DIR"
        return 1
    fi

    # 2. Find the most recently modified session directory containing a markdown report
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
        echo "❌ Error: No session folder containing a markdown report (*.md) found in: $BRAIN_DIR"
        return 1
    fi

    local AUDIT_FILENAME=$(basename "$AUDIT_FILE")

    # 3. Generate the date-based folder path
    local DATE_FOLDER="${AUDIT_DEST_ROOT}/$(date +%Y-%m-%d)"
    mkdir -p "$DATE_FOLDER"
    local TARGET_FILE="${DATE_FOLDER}/${AUDIT_FILENAME}"

    # 4. Copy the audit report
    cp "$AUDIT_FILE" "$TARGET_FILE"

    echo "🎉 Successfully exported audit report!"
    echo "📂 Destination: $TARGET_FILE"
    echo ""

    # 5. Stream file to delta for syntax-themed diff rendering (if delta is installed)
    if command -v delta >/dev/null; then
        echo "🎨 Rendering visual diffs via Delta..."
        cat "$TARGET_FILE" | delta --side-by-side --syntax-theme="Nord"
    fi

    # 6. Open the exported report in One Markdown (macOS)
    if [[ "$OSTYPE" == "darwin"* ]] && command -v open >/dev/null; then
        echo "📖 Opening audit report in One Markdown..."
        open -a "One Markdown" "$TARGET_FILE"
    elif command -v glow >/dev/null; then
        echo "📖 Rendering markdown document via Glow..."
        glow -p "$TARGET_FILE"
    else
        # Fallback to opening default editor on macOS
        if command -v open >/dev/null; then
            open "$TARGET_FILE"
        fi
    fi
}

# ==============================================================================
# 5. QUICK-ACCESS HISTORICAL LEDGER ALIASES
# ==============================================================================
# View the entire history markdown file beautifully rendered via glow
alias glog='glow -p ~/.gemini_history.md'

# Stream your entire history file through delta's visual side-by-side layout
alias gdiff='cat ~/.gemini_history.md | delta --side-by-side --syntax-theme="Nord"'

# Quickly check if the current directory is a Git repository
alias gis='git rev-parse --is-inside-work-tree'

# Clone a Git repository quickly
alias gc='git clone'

# Capture screen to both Pictures folder (unique timestamp) and Clipboard
unalias snap 2>/dev/null
snap() {
    local filepath="$HOME/Pictures/Screenshots/Screenshot_$(date +%Y%m%d_%H%M%S).png"
    screencapture "$filepath"
    if [ -f "$filepath" ]; then
        osascript -e "set the clipboard to (read (POSIX file \"$filepath\") as «class PNGf»)"
        echo "Captured: $filepath (and copied to clipboard)"
    fi
}

# Initialize the automated post-commit audit hook in the current Git repository
agyih() {
    # 1. Verify we are in a Git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "❌ Error: Not inside a Git repository."
        return 1
    fi

    local hook_file=".git/hooks/post-commit"

    # 2. Write the post-commit hook content
    cat << 'EOF' > "$hook_file"
#!/usr/bin/env zsh
# Automated Git Hook: Logs commit details and diffs to the master ledger ~/.gemini_history.md
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
    echo "### 📂 Modified Files"
    echo "\`\`\`text"
    echo "$mod_files"
    echo "\`\`\`"
    echo ""
    echo "### 🛠️ Code Mutations & Line-by-Line Diffs"
    if [[ -n "$git_diff" ]]; then
        echo "\`\`\`diff"
        echo "$git_diff"
        echo "\`\`\`"
    else
        echo "_No file changes._"
    fi
    echo ""
} >> "$log_file"

echo -e "\033[32m[*] Successfully logged commit $commit_hash to ~/.gemini_history.md\033[0m"
EOF

    # 3. Make the hook executable
    chmod +x "$hook_file"

    echo "🎉 Successfully installed automated Git post-commit logging hook!"
    echo "📂 Hook location: $hook_file"
}
