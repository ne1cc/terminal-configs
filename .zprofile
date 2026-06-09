eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Dotfiles repo location — update this if you ever move the repo
export DOTFILES="$HOME/Github/terminal-configs"

# Custom scripts (bin/ in the dotfiles repo, stow'd to ~/bin)
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
