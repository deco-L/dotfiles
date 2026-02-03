source "${0:h}/fzf_keybinds.zsh"
if [[ -n "${ZENO_ROOT:-}" ]]; then
  :
else
  source "${0:h}/fzf_completion.zsh"
fi

