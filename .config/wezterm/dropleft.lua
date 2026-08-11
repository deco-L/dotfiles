-- ドロップレフトターミナル専用の設定(画面左から WIDTH_RATIO ぶんせり出す)
-- toggle-dropleft-terminal.sh (Raycast) がこの設定で別プロセスの wezterm を起動する
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

local config = wezterm.config_builder()

require("fonts").apply_to_config(config)
require("themes").apply_to_config(config)
require("keybind").apply_to_config(config, act, wezterm) -- メインと同じキーバインド

config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.85 -- メインと同じ透過

-- AeroSpace の on-window-detected ルールで識別するための固定タイトル
wezterm.on("format-window-title", function()
	return "dropleft-terminal"
end)

local WIDTH_RATIO = 0.45

-- set_position は「画面原点からの相対座標」を取る。screen.x/y を足すと
-- オフセットのあるディスプレイ(外部モニタ等)で二重加算になりずれる。
-- 左端固定なので x = 0。
local function fit_to_screen(gui_win)
	local screen = wezterm.gui.screens().active
	local want_w = math.floor(screen.width * WIDTH_RATIO)
	gui_win:set_inner_size(want_w, screen.height)
	gui_win:set_position(0, 0)
	local dims = gui_win:get_dimensions()
	wezterm.log_info(string.format(
		"[dropleft] screen=%dx%d @%d,%d dpi=%s | want_w=%d | actual=%dx%d",
		screen.width, screen.height, screen.x, screen.y, tostring(dims.dpi),
		want_w, dims.pixel_width, dims.pixel_height))
end

-- 起動時に配置
wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	fit_to_screen(window:gui_window())
end)

-- 呼び出される(=フォーカスされる)たびに、その時のディスプレイに合わせて再配置
wezterm.on("window-focus-changed", function(window, pane)
	if window:is_focused() then
		fit_to_screen(window)
	end
end)

return config
