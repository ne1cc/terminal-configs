# Modern Developer CLI & Workflow Guide

This guide details the modern command-line tools, shell aliases, and tmux configurations that have been integrated into your environment.

---

## 1. Directory Navigation & Project Management

### 🚀 Zoxide (Smart `cd` replacement)
`zoxide` keeps track of the directories you visit. You can jump directly to any directory using a partial name match:
- **Usage**: `z <partial-name>`
  - *Example*: `z term` takes you straight to `~/Github/2026/terminal-configs`.
- **Interactive Search**: `zi`
  - Opens a fuzzy list (`fzf`) of your most visited folders to select and jump immediately.

### 🗂️ Tmux Sessionizer (Fuzzy Project Switcher)
Quickly browse and jump between active development sessions without manually creating tmux instances:
- **Shortcut**: **`Prefix + f`**
  - Spawns a floating fuzzy finder (`fzf`) showing all folders in `~/Github` and `~/Github/2026`.
  - Selecting a folder automatically attaches to its existing session or spawns a new one in the background and switches to it.

---

## 2. Interactive Git Integrations

### 🌿 Interactive Git Checkout (`gb`)
Quickly switch git branches:
- **Command**: `gb`
- **Interface**: Opens an interactive `fzf` window showing all local branches. As you arrow through branches, the preview pane on the right displays the branch's recent commit history graph dynamically. Press `Enter` to check out the branch.

### 📜 Interactive Commit browser (`gshow`)
Fuzzy find and inspect commits:
- **Command**: `gshow`
- **Interface**: Lists all git commits. Selecting a commit displays its full diff in a live preview pane on the right. Press `Enter` to open the full diff in your pager (`less`).

---

## 3. Modern Command Line Replacements

Your shell has been updated to automatically use modern, enhanced replacements for standard utilities:

### 📁 `eza` (replaces `ls`)
A modern file lister with colors and icons:
- `ls` / `ll` / `la` are now mapped to `eza`.
- Includes directory structure indicators, git change statuses, and file icons.
- **Tree view command**: `tree` (renders file trees with icons).

### 📄 `bat` (replaces `cat`)
A syntax-highlighter for file outputs:
- `cat` is now mapped to `bat`.
- Displays file content with syntax colors, line numbers, and inline git change highlights.

---

## 4. Environment Automation

### 🔑 `direnv` (Auto Environment Variables)
Automatically loads variables from `.envrc` files as you traverse directories:
- **Usage**: Create an `.envrc` file inside a project containing environment variables (e.g. `export SECRET_TOKEN="xyz"`).
- Run `direnv allow` inside the folder once to authorize it.
- As soon as you `cd` into that folder, your shell automatically loads the environment variables; when you `cd` out, they are unloaded.

---

## 5. Screen Layout & Multiplexing (Tmux)

### 📐 Smart Layout-Aware Splits
- **Shortcut**: **`Prefix + v`**
  - Splits the window horizontally (side-by-side) if your screen is wide, or vertically (stacked) if your terminal window is narrow. Keeps your current working directory.

### 💡 Focus Dimming
- Inactive panes are automatically dimmed (`fg=#a9b1d6, bg=#16161e`) relative to your active focused pane (`fg=#c0caf5, bg=#1a1b26`), giving you a strong visual guide of where your cursor is positioned.
