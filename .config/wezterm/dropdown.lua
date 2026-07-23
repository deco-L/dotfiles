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

-- 起動時に画面上部いっぱいに配置する
wezterm.on("gui-startup", function(cmd)
	local screen = wezterm.gui.screens().active
	local _, _, window = mux.spawn_window(cmd or {})
	local gui_win = window:gui_window()
	gui_win:set_position(screen.x, screen.y)
	gui_win:set_inner_size(screen.width, math.floor(screen.height * 0.45))
end)

return config
