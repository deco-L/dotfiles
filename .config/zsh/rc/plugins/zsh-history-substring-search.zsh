if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  bindkey '^k' history-substring-search-up
  bindkey '^j' history-substring-search-down
else
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi
