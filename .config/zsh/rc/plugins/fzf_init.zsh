source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/rc/plugins/fzf_keybinds.zsh"
if [[ -n "${ZENO_ROOT:-}" ]]; then
  :
else
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/rc/plugins/fzf_completion.zsh"
fi

