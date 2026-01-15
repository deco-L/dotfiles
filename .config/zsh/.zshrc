# sheldon
cache_dir=''${XDG_CACHE_HOME:-$HOME/.cache}
sheldon_cache="$cache_dir/sheldon.zsh"
sheldon_toml="$HOME/.config/sheldon/plugins.toml"
if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  mkdir -p $cache_dir
  sheldon source > "$sheldon_cache"
  zcompile "$sheldon_cache"
fi
source "$sheldon_cache"
unset cache_dir sheldon_cache sheldon_toml

# options
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt share_history

# completion
autoload -Uz compinit
compinit -d ~/.zcompdump

# zoxide
_zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zoxide.zsh"
if [[ ! -r "$_zoxide_cache" || "$(command -v zoxide)" -nt "$_zoxide_cache" ]]; then
  zoxide init zsh > "$_zoxide_cache"
  zcompile "$_zoxide_cache"
fi
source "$_zoxide_cache"
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

# aliases
source ${ZRCDIR}/alias.sh

# init
fastfetch

