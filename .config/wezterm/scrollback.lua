local module = {}
local copy_mode = nil
local search_mode = nil

local function remove_binding(tbl, key, mods)
	for i = #tbl, 1, -1 do
		local b = tbl[i]
		if b.key == key and (b.mods or "NONE") == (mods or "NONE") then
			table.remove(tbl, i)
		end
	end
end

function module.apply_to_config(config, act, gui)
	if not gui then
		return
	end
	config.key_tables = config.key_tables or {}
	search_mode = gui.default_key_tables().search_mode
	remove_binding(search_mode, "n", "CTRL")
	remove_binding(search_mode, "p", "CTRL")
	table.insert(search_mode, { key = "[", mods = "CTRL", action = act.CopyMode("Close") })
	table.insert(search_mode, { key = "j", mods = "CTRL", action = act.CopyMode("NextMatch") })
	table.insert(search_mode, { key = "k", mods = "CTRL", action = act.CopyMode("PriorMatch") })
	config.key_tables.search_mode = search_mode
end

return module
