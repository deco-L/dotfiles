#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Dropdown Terminal
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🖥️
# @raycast.packageName WezTerm

# ドロップダウン専用 wezterm(dropdown.lua で起動した別プロセス)を
# AeroSpace のワークスペース移動でトグルする。
# macOS のアプリ hide は同一バンドルの複数プロセスで巻き添えが起きるため使わない。
# - 未起動: dropdown.lua で起動(gui-startup が画面上部に配置、AeroSpace ルールで floating)
# - フォーカス中: 退避ワークスペースへ移動(=消える)
# - 同じワークスペースにいる/退避中: 今のワークスペースへ呼び出してフォーカス

AEROSPACE=/opt/homebrew/bin/aerospace
WEZTERM_APP="/Applications/WezTerm.app"
CONFIG="$HOME/.config/wezterm/dropdown.lua"
STASH_WS="drop" # 退避先ワークスペース名

WID=$("$AEROSPACE" list-windows --all --format '%{window-id}|%{window-title}' | awk -F'|' '$2 == "dropdown-terminal" {print $1; exit}')

if [ -z "$WID" ]; then
  # バイナリ直叩きだと macOS の TCC で WezTerm.app に付与した権限(FDA/Documents 等)が
  # 効かず ~/Documents 配下で Permission denied になる。open 経由で LaunchServices に
  # 起動させ、アプリバンドルの権限を継がせる。
  open -na "$WEZTERM_APP" --args --config-file "$CONFIG"
  # on-window-detected がタイトル未設定のタイミングで取りこぼした場合の保険
  sleep 1
  title=$("$AEROSPACE" list-windows --focused --format '%{window-title}' 2>/dev/null)
  if [ "$title" = "dropdown-terminal" ]; then
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
