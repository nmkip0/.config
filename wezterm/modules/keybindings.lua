local wezterm = require("wezterm")

local M = {}

function M.init(config)
	local action = wezterm.action
	config.keys = {
		{
			mods = "CTRL",
			key = "v",
			action = action.SplitHorizontal({
				cwd = wezterm.home_dir,
			}),
		},
		{
			mods = "CTRL",
			key = "s",
			action = action.SplitVertical({
				cwd = wezterm.home_dir,
			}),
		},
		{
			mods = "CMD",
			key = "w",
			action = action.CloseCurrentPane({ confirm = false }),
		},
		{
			mods = "CMD|SHIFT",
			key = "Enter",
			action = action.TogglePaneZoomState,
		},

		{
			mods = "CTRL",
			key = "h",
			action = action.ActivatePaneDirection("Left"),
		},
		{
			mods = "CTRL",
			key = "l",
			action = action.ActivatePaneDirection("Right"),
		},
		{
			mods = "CTRL",
			key = "k",
			action = action.ActivatePaneDirection("Up"),
		},
		{
			mods = "CTRL",
			key = "j",
			action = action.ActivatePaneDirection("Down"),
		},
		{
			mods = "CMD|SHIFT",
			key = "h",
			action = action.ActivateTabRelative(-1),
		},
		{
			mods = "CMD|SHIFT",
			key = "l",
			action = action.ActivateTabRelative(1),
		},
	}
end

return M
