--@ Wezterm
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local desktop_manager = os.getenv("XDG_CURRENT_DESKTOP")

-- Wayland backend is unstable
config.enable_wayland = false

-- Automatically reload when it is detected as changing.
config.automatically_reload_config = true

require("themes").apply_to_config(config)
require("fonts").apply_to_config(config)
require("appearance").apply_to_config(config)

return config
