# ==============================================================================
# LOCALE CONFIGURATION (Fix macOS ICU locale extensions in bash/subshells)
# ==============================================================================
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# Homebrew — macOS (Apple Silicon / Intel) and Linux (Linuxbrew)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv zsh)"
elif [[ -x "$HOME/.homebrew/bin/brew" ]]; then
    eval "$("$HOME/.homebrew/bin/brew" shellenv zsh)"
elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Dotfiles repo location — update this if you ever move the repo
export DOTFILES="$HOME/Github/ne1cc/terminal-configs"

# Github workspace root (portfolio + explore + config)
export GITHUB_ROOT="$HOME/Github"
export NE1CC_DIR="$GITHUB_ROOT/ne1cc"

# repo-summarize AI backend (public default is `agy -p`; this setup keeps YOLO mode)
export REPO_SUMMARIZE_CMD="agyy -p"

# Claude Code Agent Teams & Autocompact Window
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
export CLAUDE_CODE_AUTO_COMPACT_WINDOW="200k"

# Custom scripts (bin/ in the dotfiles repo, stow'd to ~/bin)
export PATH="$HOME/Github/_tools:$HOME/bin:$HOME/.local/bin:$PATH"

# OrbStack — macOS only
[[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh

# QODER_DISPATCHER_PATH v1
path=("$HOME/.qoder/entry" ${path:#"$HOME/.qoder/entry"})
export PATH
# END QODER_DISPATCHER_PATH v1
