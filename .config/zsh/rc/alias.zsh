# alias
# cat
alias cat='bat'
# ls
alias ls='eza --color=auto'
# grep
alias grep='rg -S --hidden'
alias rg='rg -S --hidden'
# # curl
alias patto='curl parrot.live'
alias weather='curl wttr.in/japan'
# # pbcopy & pbpaste
# alias pbcopy='wl-copy'
# alias pbpaste='wl-paste'
# scratch: 保存不要の使い捨てnvim(ログ・文字列の整形用)
# そのまま起動 or パイプで流し込める: cat error.log | scratch / pbpaste | scratch
scratch() {
  if [ -t 0 ]; then
    nvim -c 'setlocal buftype=nofile bufhidden=hide noswapfile' -c 'file scratch'
  else
    nvim -c 'setlocal buftype=nofile bufhidden=hide noswapfile' -c 'file scratch' -
  fi
}
# # git
alias gitmain='sh ~/Script/gitmain.sh'
alias gitsub='sh ~/Script/gitsub.sh'
alias gitp='sh ~/Script/gitdeco.sh'
alias gitlog='git log --graph --abbrev-commit --decorate'
