-- ドロップアップターミナル専用の設定(画面下から78%せり上がる)
-- toggle-dropup-terminal.sh (Raycast) がこの設定で別プロセスの wezterm を起動する
-- 用途: メイン(zeus + claude)を残したまま、別リポジトリ(front 等)を上に重ねて編集する
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
	return "dropup-terminal"
end)

local HEIGHT_RATIO = 0.78

-- 今いる画面の下部から HEIGHT_RATIO ぶんせり上げて配置する。
-- set_inner_size は行単位に丸められ、装飾ぶんも加わるため、実寸を測って
-- 下端が画面下辺にそろうよう再配置する(丸め・DPI・装飾の差を吸収)。
-- set_position は「画面原点からの相対座標」を取る。screen.x/y を足すと
-- オフセットのあるディスプレイ(外部モニタ等)で二重加算になり隙間ができる。
--
-- さらに set_inner_size は行単位に丸められるうえ、その丸めは dpi(セルの実ピクセル高)
-- に依存する。resize が非同期に効くため、直後の get_dimensions では丸め後の実寸を
-- 取り切れないことがある。そこで一度置いたあとに再計測して置き直す。
local function place(gui_win, screen, tag)
	local dims = gui_win:get_dimensions()
	local y = screen.height - dims.pixel_height
	gui_win:set_position(0, y)
	wezterm.log_info(string.format(
		"[dropup:%s] screen=%dx%d @%d,%d dpi=%s | actual=%dx%d | set_y=%d | gap=%d",
		tag, screen.width, screen.height, screen.x, screen.y, tostring(dims.dpi),
		dims.pixel_width, dims.pixel_height, y,
		screen.height - (y + dims.pixel_height)))
	return dims
end

local function fit_to_screen(gui_win)
	local screen = wezterm.gui.screens().active
	local want_h = math.floor(screen.height * HEIGHT_RATIO)
	gui_win:set_inner_size(screen.width, want_h)
	wezterm.log_info(string.format("[dropup] want_h=%d", want_h))
	place(gui_win, screen, "first")
	-- resize が反映されたあとの実寸で置き直す(丸め・dpi・装飾の差を吸収)。
	-- screens().active はここで再取得してはいけない: 150ms の間に別ディスプレイ
	-- (フォーカスの移動先)を返すことがあり、内蔵の高さで外部モニタ上のウィンドウを
	-- 配置して壊れる。最初に捕まえた screen を使い、寸法が dpi 遷移中の中間値
	-- (画面幅と一致しない)なら見送る。
	wezterm.time.call_after(0.15, function()
		local ok, err = pcall(function()
			local dims = gui_win:get_dimensions()
			if dims.pixel_width ~= screen.width then
				wezterm.log_info(string.format(
					"[dropup:skip] 遷移中のため見送り actual=%dx%d screen_w=%d",
					dims.pixel_width, dims.pixel_height, screen.width))
				return
			end
			place(gui_win, screen, "recheck")
		end)
		if not ok then
			wezterm.log_error("[dropup] recheck failed: " .. tostring(err))
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
