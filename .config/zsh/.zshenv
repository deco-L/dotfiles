# XDG
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"

# zsh
export ZSHCONF="${XDG_CONFIG_HOME}/zsh"
export ZRCDIR="${ZSHCONF}/rc"

# lang
export LANG="en_US.UTF-8"
export LC_ALL="${LANG}"
export LC_CTYPE="${LANG}"

# path
export PATH="$PATH:$HOME/.cargo/bin"

# editor
export EDITOR="nvim"
export GIT_EDITOR="${EDITOR}"

