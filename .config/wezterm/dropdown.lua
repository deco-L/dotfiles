-- ドロップダウンターミナル専用の設定
-- toggle-dropdown-terminal.sh (Raycast) がこの設定で別プロセスの wezterm を起動する
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
	return "dropdown-terminal"
end)

local HEIGHT_RATIO = 0.45

-- 今いる画面の上部いっぱいに配置する。
-- set_position は「画面原点からの相対座標」を取る。screen.x/y を足すと
-- オフセットのあるディスプレイ(外部モニタが @1512,-98 のように非ゼロ原点を持つ配置)で
-- 二重加算になり、ウィンドウがその分ずれて画面外にはみ出す。
-- 内蔵ディスプレイは原点 @0,0 なので足しても無害で気づけない。
local function fit_to_screen(gui_win)
	local screen = wezterm.gui.screens().active
	local want_h = math.floor(screen.height * HEIGHT_RATIO)
	gui_win:set_inner_size(screen.width, want_h)
	local dims = gui_win:get_dimensions()
	-- デバッグ計測(ディスプレイ差の切り分け用。dpi は Retina=144 / 非Retina=72)
	wezterm.log_info(string.format(
		"[dropdown] screen=%dx%d @%d,%d dpi=%s | want_h=%d | actual=%dx%d",
		screen.width, screen.height, screen.x, screen.y, tostring(dims.dpi),
		want_h, dims.pixel_width, dims.pixel_height))
	-- 上端固定なので相対座標の原点そのもの
	gui_win:set_position(0, 0)
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
