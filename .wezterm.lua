local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.enable_wayland = false

-- config.color_scheme = "Brush Trees Dark (base16)"
-- config.color_scheme = "Ocean"
config.color_scheme = "Aardvark Blue"
config.font = wezterm.font("Hack Nerd Font")
config.enable_tab_bar = false

return config
