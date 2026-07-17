local module = {}

function module.apply_to_config(config, wezterm)
	config.enable_tab_bar = false

	-- config.window_decoration = "NONE"
	config.window_background_opacity = 0.85

	wezterm.on("gui-startup", function(cmd)
		local _, _, window = wezterm.mux.spawn_window(cmd or {})
		window:gui_window():maximize()
	end)

	wezterm.on("format-window-title", function(tab, pane, tabs, panes, cfg)
		local workspace = wezterm.mux.get_window(tab.window_id):get_workspace()
		return workspace .. " | " .. tab.active_pane.title
	end)
end

return module
