#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Peek Claude Session
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 👀
# @raycast.packageName WezTerm

# 最後に通知を出した Claude セッションの pane を、いま見ている画面の中央に
# floating でせり出す/元の split に差し戻すトグル。
# 候補が複数あるときは fzf の選択ウィンドウが先に出る。
# 実体は wezterm 側に置いてある(hooks の記録・events.lua の配置と一体のため)。
exec "$HOME/.config/wezterm/peek-claude.sh" toggle
