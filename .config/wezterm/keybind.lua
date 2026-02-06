local module = {}
local search_mode = nil

local function search_mode_keybinds(key_tables, act)
	key_tables.search_mode = {
		{ key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "[", mods = "CTRL", action = act.CopyMode("Close") },
		{ key = "j", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "k", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
		{
			key = "PageUp",
			mods = "NONE",
			action = act.CopyMode("PriorMatchPage"),
		},
		{
			key = "PageDown",
			mods = "NONE",
			action = act.CopyMode("NextMatchPage"),
		},
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
	}
end

function module.apply_to_config(config, act)
	config.key_tables = config.key_tables or {}

	search_mode_keybinds(config.key_tables, act)
end

return module
