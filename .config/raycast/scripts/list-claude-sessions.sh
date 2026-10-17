#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Claude Sessions
# @raycast.mode fullOutput
#
# Optional parameters:
# @raycast.icon 📋
# @raycast.packageName WezTerm

# 動いている Claude Code セッションを、状態(⏳待ち / ✅完了)と経過時間つきで一覧する。
# 状態は端末出力の推測ではなく Claude Code の hooks (Notification / Stop) から来た事実。
# データ源: ~/.local/state/claude-activity/YYYY-MM.tsv（claude-notify.sh が追記）
# 実体: ~/.local/bin/claude-sessions

exec "$HOME/.local/bin/claude-sessions" "$@"
