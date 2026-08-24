# Taskwarrior & Git Integration Guide

This guide covers setting up Taskwarrior, `taskwarrior-tui`, minimal `.taskrc` production configuration, and automated Git hook integration on **macOS** and **Linux**.

**See also:** [docs/README.md](README.md) · [ZSH_GIT_WORKFLOW_GUIDE.md](ZSH_GIT_WORKFLOW_GUIDE.md)

---

## 1. Quick Installation

### macOS (Homebrew)
```bash
brew install task taskwarrior-tui
```

### Ubuntu / Debian
```bash
sudo apt update && sudo apt install -y taskwarrior
```

### Arch Linux
```bash
sudo pacman -S task taskwarrior-tui
```

---

## 2. Global Shell Aliases & Shortcuts

The following aliases are auto-loaded by `terminal-configs`:

```bash
alias t='task'
alias ta='task add'
alias tl='task list'
alias tn='task next'
alias tui='taskwarrior-tui'
alias tdev='task project:dev list'
```

---

## 3. Git Hook Integration

To enable auto-completion of Taskwarrior tasks when writing commit messages (e.g. `fixes task #4` or `closes task 12`), run the helper script in any target Git repository:

```bash
git-install-taskwarrior-hook /path/to/your-repo
```

Or run inside your target repository directory:
```bash
git-install-taskwarrior-hook .
```

### How it works
When you write a commit like:
```bash
git commit -m "Refactor token validation logic (fixes task #1)"
```

The hook automatically checks Taskwarrior for pending task `#1` and runs `task 1 done`.
