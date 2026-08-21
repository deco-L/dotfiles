#!/bin/bash
# peek-claude.sh — Claude Code が動いている pane を、いま見ている画面の中央に
# floating ウィンドウとして「せり出し」、もう一度呼ぶと元の split 位置へ差し戻す。
#
# 仕組み:
# - Claude Code の hooks (claude-notify.sh) が通知のたびに pane id を記録している
# - せり出し: 差し戻しに必要な幾何(隣の pane・方向・比率)を記録してから
#   `wezterm cli move-pane-to-new-tab --new-window` で今のワークスペースに独立させ、
#   AeroSpace で floating 化 + events.lua (SetUserVar peek-place) で中央に配置
# - 差し戻し: `wezterm cli split-pane --move-pane-id` で記録した隣の split に戻す
#   (2分割レイアウトなら元通り。3枚以上の入れ子は最初の隣で近似)
# - 候補が複数あるときは fzf の選択ウィンドウを先にせり出す
#
# 使い方: peek-claude.sh [toggle]   … Raycast から呼ぶトグル
#         peek-claude.sh peek <id>  … pane id 直指定(デバッグ用)

WEZTERM=/opt/homebrew/bin/wezterm
AEROSPACE=/opt/homebrew/bin/aerospace
JQ=/usr/bin/jq
FZF=/opt/homebrew/bin/fzf
NOTIFIER=/opt/homebrew/bin/terminal-notifier

STATE_DIR="$HOME/.local/state/claude-peek"
ACTIVE="$STATE_DIR/active"   # せり出し中の pane の差し戻し情報(タブ区切り1行)
PANES_LOG="$STATE_DIR/panes" # hooks が記録した通知元 pane id(新しい順)
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
mkdir -p "$STATE_DIR"

list_json() { "$WEZTERM" cli list --format json; }

active_workspace() {
  "$WEZTERM" cli list-clients --format json | "$JQ" -r '.[0].workspace'
}

# いまの WezTerm ウィンドウ集合(AeroSpace の id)。新規ウィンドウ検出に使う
wezterm_window_ids() {
  "$AEROSPACE" list-windows --all --format '%{window-id}|%{app-bundle-id}' |
    awk -F'|' '$2 == "com.github.wez.wezterm" {print $1}' | sort
}

# $1(実行前の id 集合)と比較して新しく現れたウィンドウを floating 化してフォーカス
float_new_window() {
  local before="$1" added
  for _ in $(seq 1 25); do
    added=$(comm -13 <(printf '%s\n' "$before") <(wezterm_window_ids) | head -1)
    if [ -n "$added" ]; then
      "$AEROSPACE" layout floating --window-id "$added" 2>/dev/null
      "$AEROSPACE" focus --window-id "$added" 2>/dev/null
      return 0
    fi
    sleep 0.2
  done
  return 1
}

# events.lua の peek-place ハンドラに配置を頼む($1 = そのウィンドウ内の pane id)
place_window() {
  local tty
  tty=$(list_json | "$JQ" -r --argjson p "$1" '.[]|select(.pane_id==$p).tty_name // empty')
  [ -n "$tty" ] &&
    printf '\033]1337;SetUserVar=peek-place=%s\a' "$(printf %s "$1" | /usr/bin/base64)" > "$tty"
}

# 差し戻し情報を ACTIVE に記録($1 = pane id)。書式:
# pane <TAB> 元workspace <TAB> 元window <TAB> 隣pane(なければ none) <TAB> 方向 <TAB> 比率%
record_geometry() {
  list_json | "$JQ" -r --argjson p "$1" '
    . as $all | ($all[] | select(.pane_id == $p)) as $c
    | ([$all[] | select(.tab_id == $c.tab_id and .pane_id != $c.pane_id)][0]) as $n
    | if $n == null then "\($c.pane_id)\t\($c.workspace)\t\($c.window_id)\tnone\tright\t50"
      else
        (if $c.top_row == $n.top_row
         then (if $c.left_col > $n.left_col then "right" else "left" end) + "\t"
              + (($c.size.cols * 100 / ($c.size.cols + $n.size.cols)) | round | tostring)
         else (if $c.top_row > $n.top_row then "bottom" else "top" end) + "\t"
              + (($c.size.rows * 100 / ($c.size.rows + $n.size.rows)) | round | tostring)
         end) as $dp
        | "\($c.pane_id)\t\($c.workspace)\t\($c.window_id)\t\($n.pane_id)\t\($dp)"
      end' > "$ACTIVE"
}

# 記録済み pane のうち、いまも生きているものを新しい順に出す
live_candidates() {
  local json live
  json=$(list_json)
  [ -f "$PANES_LOG" ] || return 0
  while IFS= read -r p; do
    live=$("$JQ" -r --argjson p "$p" '[.[]|select(.pane_id==$p)]|length' <<<"$json")
    [ "$live" = "1" ] && echo "$p"
  done < "$PANES_LOG"
}

peek_pane() {
  local c="$1" before
  record_geometry "$c"
  before=$(wezterm_window_ids)
  "$WEZTERM" cli move-pane-to-new-tab --pane-id "$c" --new-window \
    --workspace "$(active_workspace)" >/dev/null
  float_new_window "$before"
  place_window "$c"
  "$WEZTERM" cli activate-pane --pane-id "$c" 2>/dev/null
}

restore_pane() {
  local c ws win neighbor dir pct json
  IFS=$'\t' read -r c ws win neighbor dir pct < "$ACTIVE"
  rm -f "$ACTIVE"
  json=$(list_json)
  # せり出し中に pane が閉じられていたら何もしない
  [ "$("$JQ" -r --argjson p "$c" '[.[]|select(.pane_id==$p)]|length' <<<"$json")" = "1" ] || return 0
  if [ "$neighbor" != "none" ] &&
     [ "$("$JQ" -r --argjson p "$neighbor" '[.[]|select(.pane_id==$p)]|length' <<<"$json")" = "1" ]; then
    "$WEZTERM" cli split-pane --pane-id "$neighbor" --"$dir" --percent "$pct" \
      --move-pane-id "$c" >/dev/null
  elif [ "$("$JQ" -r --argjson w "$win" --argjson p "$c" \
        '[.[]|select(.window_id==$w and .pane_id!=$p)]|length' <<<"$json")" -ge 1 ]; then
    # 隣がいない(Claude 専用タブだった)/消えていた → 元のウィンドウのタブとして戻す
    "$WEZTERM" cli move-pane-to-new-tab --pane-id "$c" --window-id "$win" >/dev/null
  else
    # 元のウィンドウごと消えていたら元のワークスペースに独立ウィンドウとして戻す
    "$WEZTERM" cli move-pane-to-new-tab --pane-id "$c" --new-window --workspace "$ws" >/dev/null
  fi
  "$WEZTERM" cli activate-pane --pane-id "$c" 2>/dev/null
}

# 複数候補: 選択用の floating ウィンドウを出し、その中で _menu を動かす
open_chooser() {
  local before pane_id
  before=$(wezterm_window_ids)
  pane_id=$("$WEZTERM" cli spawn --new-window --workspace "$(active_workspace)" \
    -- /bin/bash "$SELF" _menu)
  float_new_window "$before"
  place_window "$pane_id"
}

# 選択ウィンドウの中身。選んだ pane を自分のウィンドウへ引き込み、自分は消える
cmd_menu() {
  local json sel c win
  json=$(list_json)
  sel=$(live_candidates | while IFS= read -r p; do
      "$JQ" -r --argjson p "$p" '.[]|select(.pane_id==$p)|"\(.pane_id)\t[\(.workspace)]\t\(.title)"' <<<"$json"
    done | "$FZF" --delimiter='\t' --with-nth=2,3 --prompt='claude session> ' \
                  --header='どのセッションをせり出す? (Esc でキャンセル)')
  c=$(printf '%s' "$sel" | cut -f1)
  if [ -z "$c" ]; then
    "$WEZTERM" cli kill-pane --pane-id "$WEZTERM_PANE" 2>/dev/null
    exit 0
  fi
  record_geometry "$c"
  win=$(list_json | "$JQ" -r --argjson p "${WEZTERM_PANE:--1}" '.[]|select(.pane_id==$p).window_id')
  "$WEZTERM" cli move-pane-to-new-tab --pane-id "$c" --window-id "$win" >/dev/null
  "$WEZTERM" cli activate-pane --pane-id "$c" 2>/dev/null
  "$WEZTERM" cli kill-pane --pane-id "$WEZTERM_PANE" 2>/dev/null
}

cmd_toggle() {
  if [ -f "$ACTIVE" ]; then
    restore_pane
    exit 0
  fi
  local candidates n
  candidates=$(live_candidates)
  n=$(printf '%s' "$candidates" | grep -c . || true)
  if [ "$n" -eq 0 ]; then
    "$NOTIFIER" -title 'Claude Peek' -message '対象の Claude セッションがありません' \
      -group claude-peek 2>/dev/null || true
  elif [ "$n" -eq 1 ]; then
    peek_pane "$candidates"
  else
    open_chooser
  fi
}

case "${1:-toggle}" in
  toggle) cmd_toggle ;;
  peek) peek_pane "$2" ;;
  restore) restore_pane ;;
  _menu) cmd_menu ;;
  *) echo "usage: $0 [toggle|peek <pane-id>|restore]" >&2; exit 1 ;;
esac
