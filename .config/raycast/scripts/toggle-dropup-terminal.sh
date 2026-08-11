#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Dropup Terminal
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🗔
# @raycast.packageName WezTerm

# ドロップアップ専用 wezterm(dropup.lua で起動した別プロセス)を
# AeroSpace のワークスペース移動でトグルする。dropdown と同じ仕組みの別インスタンス。
# - 未起動: dropup.lua で起動(gui-startup が画面下部78%に配置、AeroSpace ルールで floating)
# - フォーカス中: 退避ワークスペースへ移動(=消える)
# - 同じワークスペースにいる/退避中: 今のワークスペースへ呼び出してフォーカス

AEROSPACE=/opt/homebrew/bin/aerospace
WEZTERM_APP="/Applications/WezTerm.app"
CONFIG="$HOME/.config/wezterm/dropup.lua"
STASH_WS="dropu" # 退避先ワークスペース名(dropdown の "drop" と別にする)

WID=$("$AEROSPACE" list-windows --all --format '%{window-id}|%{window-title}' | awk -F'|' '$2 == "dropup-terminal" {print $1; exit}')

if [ -z "$WID" ]; then
  # バイナリ直叩きだと macOS の TCC で WezTerm.app に付与した権限(FDA/Documents 等)が
  # 効かず ~/Documents 配下で Permission denied になる。open 経由で LaunchServices に
  # 起動させ、アプリバンドルの権限を継がせる。
  open -na "$WEZTERM_APP" --args --config-file "$CONFIG"
  # on-window-detected がタイトル未設定のタイミングで取りこぼした場合の保険
  sleep 1
  title=$("$AEROSPACE" list-windows --focused --format '%{window-title}' 2>/dev/null)
  if [ "$title" = "dropup-terminal" ]; then
    "$AEROSPACE" layout floating
  fi
  exit 0
fi

FOCUSED=$("$AEROSPACE" list-windows --focused --format '%{window-id}' 2>/dev/null)
CUR=$("$AEROSPACE" list-workspaces --focused)

if [ "$FOCUSED" = "$WID" ]; then
  # フォーカス中 → 退避してしまう
  "$AEROSPACE" move-node-to-workspace --window-id "$WID" "$STASH_WS"
elif "$AEROSPACE" list-windows --workspace "$CUR" --format '%{window-id}' | grep -qx "$WID"; then
  # 見えているがフォーカスがない → フォーカスだけ移す
  "$AEROSPACE" focus --window-id "$WID"
else
  # 退避中 or 別ワークスペース → 呼び出してフォーカス
  "$AEROSPACE" move-node-to-workspace --window-id "$WID" "$CUR"
  "$AEROSPACE" focus --window-id "$WID"
fi
