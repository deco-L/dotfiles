# vim mode
if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
else
  bindkey -v
fi

# history → zsh-history-substring-search
# autoload -U history-search-end
# zle -N history-beginning-search-backward-end history-search-end
# zle -N history-beginning-search-forward-end history-search-end
# bindkey -M vicmd "k" history-beginning-search-backward-end
# bindkey -M vicmd "j" history-beginning-search-forward-end

# edit command line
autoload edit-command-line
zle -N edit-command-line
bindkey "^[e" edit-command-line

