-- ドロップライトターミナル専用の設定(画面右から WIDTH_RATIO ぶんせり出す)
-- toggle-dropright-terminal.sh (Raycast) がこの設定で別プロセスの wezterm を起動する
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
	return "dropright-terminal"
end)

local WIDTH_RATIO = 0.45

-- 右端そろえなので dropup と同じ問題を持つ:
-- set_inner_size は桁単位に丸められるため、要求値ではなく実寸から x を逆算する。
-- set_position は「画面原点からの相対座標」を取る(screen.x を足すと二重加算)。
local function place(gui_win, screen, tag)
	local dims = gui_win:get_dimensions()
	local x = screen.width - dims.pixel_width
	gui_win:set_position(x, 0)
	wezterm.log_info(string.format(
		"[dropright:%s] screen=%dx%d @%d,%d dpi=%s | actual=%dx%d | set_x=%d | gap=%d",
		tag, screen.width, screen.height, screen.x, screen.y, tostring(dims.dpi),
		dims.pixel_width, dims.pixel_height, x,
		screen.width - (x + dims.pixel_width)))
end

local function fit_to_screen(gui_win)
	local screen = wezterm.gui.screens().active
	local want_w = math.floor(screen.width * WIDTH_RATIO)
	gui_win:set_inner_size(want_w, screen.height)
	place(gui_win, screen, "first")
	-- resize の反映は非同期。丸め後の実寸で置き直す。
	-- screens().active はここで取り直さない: 別ディスプレイを返す競合があり、
	-- 別画面の幅で配置して壊れる(dropup で実際に踏んだ)。
	wezterm.time.call_after(0.15, function()
		local ok, err = pcall(function()
			local dims = gui_win:get_dimensions()
			if dims.pixel_height ~= screen.height then
				wezterm.log_info(string.format(
					"[dropright:skip] 遷移中のため見送り actual=%dx%d screen_h=%d",
					dims.pixel_width, dims.pixel_height, screen.height))
				return
			end
			place(gui_win, screen, "recheck")
		end)
		if not ok then
			wezterm.log_error("[dropright] recheck failed: " .. tostring(err))
		end
	end)
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
