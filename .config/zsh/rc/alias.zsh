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
# claude-sound: Claude Code の完了/確認待ち通知の音を on/off する
# (~/.claude/hooks/claude-notify.sh がこのフラグファイルを見る。引数なしはトグル)
claude-sound() {
  local flag="$HOME/.local/state/claude-notify/sound-on"
  case "${1:-toggle}" in
    on) mkdir -p "${flag:h}" && touch "$flag" ;;
    off) rm -f "$flag" ;;
    toggle)
      if [ -f "$flag" ]; then
        rm -f "$flag"
      else
        mkdir -p "${flag:h}" && touch "$flag"
      fi
      ;;
    *) echo "usage: claude-sound [on|off|toggle]" >&2; return 1 ;;
  esac
  if [ -f "$flag" ]; then echo "claude 通知音: on"; else echo "claude 通知音: off"; fi
}
# # git
alias gitmain='sh ~/Script/gitmain.sh'
alias gitsub='sh ~/Script/gitsub.sh'
alias gitp='sh ~/Script/gitdeco.sh'
alias gitlog='git log --graph --abbrev-commit --decorate'
