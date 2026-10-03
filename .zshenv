# ==============================================================================
# .zshenv — Sourced on all invocations of zsh (interactive, login, and scripts)
# ==============================================================================

# SHELL MODULE & FUNCTION PATH RESOLUTION (Non-root prefix fallback)
# When zsh is installed under a user prefix (e.g. ~/.local/usr without root/sudo),
# dynamic loadable modules (.so) and standard functions reside under ~/.local/usr.
# Ensure module_path and fpath locate them so builtins (zle, zstyle) and functions load.
typeset -U module_path fpath
if [[ ! -d /usr/lib/x86_64-linux-gnu/zsh && -d "$HOME/.local/usr/lib" ]]; then
  for _zsh_lib in "$HOME"/.local/usr/lib/*-linux-gnu/zsh/"$ZSH_VERSION"(N); do
    module_path=("$_zsh_lib" $module_path)
  done
  unset _zsh_lib
fi

if [[ ! -d /usr/share/zsh/functions && -d "$HOME/.local/usr/share/zsh" ]]; then
  fpath=("${(@)fpath/#\/usr\/share\/zsh/$HOME/.local/usr/share/zsh}")
  fpath=("${(@)fpath/#\/usr\/local\/share\/zsh/$HOME/.local/usr/share/zsh}")
fi
