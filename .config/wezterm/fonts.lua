local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
	config.font = wezterm.font("Hack Nerd Font")
	config.font_size = 14
end

return module
