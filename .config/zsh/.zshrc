# sheldon
cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
sheldon_cache="$cache_dir/sheldon.zsh"
sheldon_toml="$HOME/.config/sheldon/plugins.toml"
if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  mkdir -p $cache_dir
  sheldon source > "$sheldon_cache"
  zcompile "$sheldon_cache"
fi
source "$sheldon_cache"
unset cache_dir sheldon_cache sheldon_toml

# history
HISTFILE=$HOME/.config/zsh/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# zsh-history-substring-search
zsh-defer source "$HOME/.config/zsh/rc/plugins/zsh-history-substring-search.zsh"

# completion
eval "$(dircolors)"
zstyle ':completion:*' matcher-list "" 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*:descriptions' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
function _deferred_compinit() {
  autoload -Uz compinit
  _comp_dump="''${ZDOTDIR:-$HOME}/.zcompdump"
  _comp_zwc="$_comp_dump.zwc"
  if [[ -r "$_comp_zwc" && "$_comp_zwc" -nt "$_comp_dump" ]]; then
    source "$_comp_dump"
  elif [[ -r "$_comp_dump" ]]; then
    source "$_comp_dump"
    zcompile "$_comp_dump"
  else
    compinit -d "$_comp_dump"
    zcompile "$_comp_dump"
  fi
  unset _comp_dump _comp_zwc
}
zsh-defer _deferred_compinit

# zeno
source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/rc/plugins/zeno_keybinds.zsh"

# fzf
_fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/fzf_init.zsh"
_fzf_init="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/rc/plugins/fzf_init.zsh"
if [[ ! -r "$_fzf_cache" || "$_fzf_init" -nt "$_fzf_cache" || "$(command -v fzf)" -nt "$_fzf_cache" ]]; then
  > "$_fzf_cache" < "$_fzf_init"
  zcompile "$_fzf_cache"
fi
zsh-defer source "$_fzf_cache"
unset _fzf_cache
unset _fzf_init

# zoxide
_zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zoxide.zsh"
if [[ ! -r "$_zoxide_cache" || "$(command -v zoxide)" -nt "$_zoxide_cache" ]]; then
  zoxide init zsh > "$_zoxide_cache"
  zcompile "$_zoxide_cache"
fi
zsh-defer source "$_zoxide_cache"
unset _zoxide_cache

# starship
_starship_cache="${XDG_CACHE_HOME:-$HOME/.cache}/starship.zsh"
_starship_config="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
if [[ ! -r "$_starship_cache" || "$_starship_config" -nt "$_starship_cache" || "$(command -v starship)" -nt "$_starship_cache" ]]; then
  starship init zsh > "$_starship_cache"
  zcompile "$_starship_cache"
fi
source "$_starship_cache"
unset _starship_cache _starship_config

# options
source ${ZRCDIR}/options.zsh

# aliases
source ${ZRCDIR}/alias.zsh

# bind
source ${ZRCDIR}/bind.zsh

# init
fastfetch

