#!/bin/sh
# pomo onEvent hook: 状態変化ごとに呼ばれる($POMO_STATE に新しい状態が入る)
# terminal-notifier に -sound を渡していないので通知は無音

case "$POMO_STATE" in
BREAKING)
  /opt/homebrew/bin/terminal-notifier -title 'pomo' -message '🍅 ポモドーロ終了。休憩どうぞ' -group pomo
  ;;
COMPLETE)
  /opt/homebrew/bin/terminal-notifier -title 'pomo' -message '🍅 お疲れさま。休憩どうぞ' -group pomo
  ;;
esac
