--@ Wezterm event handlers
local M = {}

function M.apply_to_config(config, wezterm)
	-- 通知クリック等の外部プロセスから OSC 1337 SetUserVar 経由で
	-- 対象 pane のワークスペースへ切り替えてフォーカスする
	-- 例: printf '\033]1337;SetUserVar=focus-pane=%s\a' "$(printf %s <pane_id> | base64)" > <tty>
	wezterm.on("user-var-changed", function(window, pane, name, value)
		if name ~= "focus-pane" then
			return
		end
		local pane_id = tonumber(value)
		if not pane_id then
			return
		end
		local mux_pane = wezterm.mux.get_pane(pane_id)
		if not mux_pane then
			return
		end
		local tab = mux_pane:tab()
		local mux_window = tab and tab:window()
		if not mux_window then
			return
		end
		wezterm.mux.set_active_workspace(mux_window:get_workspace())
		tab:activate()
		mux_pane:activate()
		local gui_win = mux_window:gui_window()
		if gui_win then
			gui_win:focus()
		end
	end)
end

return M
