-- ドロップダウンターミナル専用の設定
-- toggle-dropdown-terminal.sh (Raycast) がこの設定で別プロセスの wezterm を起動する
local wezterm = require("wezterm")
local mux = wezterm.mux

local config = wezterm.config_builder()

require("fonts").apply_to_config(config)
require("themes").apply_to_config(config)

config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.85 -- メインと同じ透過

-- AeroSpace の on-window-detected ルールで識別するための固定タイトル
wezterm.on("format-window-title", function()
	return "dropdown-terminal"
end)

-- 今いる画面の上部いっぱいに配置する
local function fit_to_screen(gui_win)
	local screen = wezterm.gui.screens().active
	gui_win:set_position(screen.x, screen.y)
	gui_win:set_inner_size(screen.width, math.floor(screen.height * 0.45))
end

-- 起動時に配置
wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	fit_to_screen(window:gui_window())
end)

-- 呼び出される(=フォーカスされる)たびに、その時のディスプレイに合わせて再配置。
-- gui-startup は起動時の画面サイズしか知らないので、外部ディスプレイ接続に追従できない
wezterm.on("window-focus-changed", function(window, pane)
	if window:is_focused() then
		fit_to_screen(window)
	end
end)

return config
