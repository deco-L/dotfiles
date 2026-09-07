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
# dpsf: docker ps の表示カラムを fzf で複数選択し、完成したコマンドを
# 編集バッファに置く(そのまま Enter で実行、編集も履歴残しも可)。
# zeno のスニペットにしなかったのは、zeno の補完挿入が必ず (q) エスケープされ、
# {{.ID}} をクォート内に挿入できないため。
dpsf() {
  local cols fmt
  cols=$(printf '%s\n' ID Names Image Status Ports RunningFor CreatedAt Size Command Networks Mounts State Labels |
    fzf --multi --prompt='Columns> ' --header='Tab で複数選択 → Enter') || return 0
  [ -n "$cols" ] || return 0
  fmt=$(printf '%s\n' "$cols" | awk '{printf "{{.%s}}\\t", $1}' | sed 's/\\t$//')
  print -z "docker ps --format 'table ${fmt}'"
}
# claude-sound: Claude Code の完了/確認待ち通知の音を on/off・変更する
# (~/.claude/hooks/claude-notify.sh がフラグファイルを見る。中身が音名)
# 引数なし: トグル / on / off / pick: fzf で試聴しながら選ぶ / <音名>: 直接指定
claude-sound() {
  local flag="$HOME/.local/state/claude-notify/sound-on" dir=/System/Library/Sounds s
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
    pick)
      s=$(command ls "$dir" | sed 's/\.aiff$//' |
        fzf --prompt='sound> ' --header='カーソル移動で試聴 / Enter で決定' \
            --preview "afplay $dir/{}.aiff" --preview-window=up,1) || return 0
      mkdir -p "${flag:h}" && print -r -- "$s" > "$flag"
      ;;
    *)
      if [ -f "$dir/$1.aiff" ]; then
        mkdir -p "${flag:h}" && print -r -- "$1" > "$flag"
        afplay "$dir/$1.aiff" >/dev/null 2>&1 &
      else
        echo "usage: claude-sound [on|off|toggle|pick|<音名>]" >&2
        echo "音名の候補: $(command ls "$dir" | sed 's/\.aiff$//' | paste -sd' ' -)" >&2
        return 1
      fi
      ;;
  esac
  if [ -f "$flag" ]; then
    echo "claude 通知音: on ($(head -1 "$flag" | grep . || echo Glass))"
  else
    echo "claude 通知音: off"
  fi
}
# # git
alias gitmain='sh ~/Script/gitmain.sh'
alias gitsub='sh ~/Script/gitsub.sh'
alias gitp='sh ~/Script/gitdeco.sh'
alias gitlog='git log --graph --abbrev-commit --decorate'
