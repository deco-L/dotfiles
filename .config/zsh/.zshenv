# XDG
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"

# zsh
export ZSHCONF="${XDG_CONFIG_HOME}/zsh"
export ZRCDIR="${ZSHCONF}/rc"

# starship
export STARSHIP_CACHE="${XDG_CACHE_HOME}/starship"

# lang
export LANG="en_US.UTF-8"
export LC_ALL="${LANG}"
export LC_CTYPE="${LANG}"

# path
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$HOME/.local/bin/:$PATH"

# bat
export BAT_CONFIG_DIR="${XDG_CONFIG_HOME}/bat"
export BAT_CONFIG_PATH="${BAT_CONFIG_DIR}/bat.conf"

# editor
export EDITOR="nvim"
export GIT_EDITOR="${EDITOR}"

# fctix5
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

# go
export GOPATH="$XDG_CACHE_HOME"/go

# zeno
export ZENO_DISABLE_EXECUTE_CACHE_COMMAND=1

