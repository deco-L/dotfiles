#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Choose Claude Session
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon ⏳
# @raycast.packageName WezTerm

# 一覧から選んでせり出す。選択ウィンドウには状態(⏳待ち / ✅完了)・経過時間・
# 何で止まっているかが出て、待ちが上・待たせている順に並ぶ
# (行は claude-sessions --fzf-lines が作る)。
# 候補が 1 つでも必ずメニューを出すので、Peek Claude Session（最後に通知を出したものを
# トグル）と使い分ける。
# 実体: ~/Programing/dotfiles/.config/wezterm/peek-claude.sh choose

exec "$HOME/Programing/dotfiles/.config/wezterm/peek-claude.sh" choose
