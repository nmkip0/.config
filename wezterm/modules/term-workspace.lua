local wez = require("wezterm")
local mux = wez.mux

local M = {}

function M.init(_)
	wez.on("gui-attached", function()
		local workspace = mux.get_active_workspace()
		if workspace ~= "term" then
			return
		end

		for _, mux_window in ipairs(mux.all_windows()) do
			local window = mux_window:gui_window()

			local overrides = window:get_config_overrides() or {}

			overrides.line_height = 1

			window:set_config_overrides(overrides)
		end
	end)
end

return M
