local wezterm = require("wezterm")

local M = {}

function M.init(config)
	local action = wezterm.action
	config.keys = {
		{
			mods = "CMD|SHIFT",
			key = "v",
			action = action.SplitHorizontal({
				cwd = wezterm.home_dir,
			}),
		},
		{
			mods = "CMD|SHIFT",
			key = "s",
			action = action.SplitVertical({
				cwd = wezterm.home_dir,
			}),
		},
		{
			mods = "CMD|SHIFT",
			key = "w",
			action = action.CloseCurrentPane({ confirm = false }),
		},
		{
			mods = "CMD|SHIFT",
			key = "Enter",
			action = action.TogglePaneZoomState,
		},

		{
			mods = "CMD|SHIFT",
			key = "h",
			action = action.ActivatePaneDirection("Left"),
		},
		{
			mods = "CMD|SHIFT",
			key = "l",
			action = action.ActivatePaneDirection("Right"),
		},
		{
			mods = "CMD|SHIFT",
			key = "k",
			action = action.ActivatePaneDirection("Up"),
		},
		{
			mods = "CMD|SHIFT",
			key = "j",
			action = action.ActivatePaneDirection("Down"),
		},
		{
			mods = "CMD|SHIFT",
			key = "LeftArrow",
			action = action.ActivateTabRelative(-1),
		},
		{
			mods = "CMD|SHIFT",
			key = "RightArrow",
			action = action.ActivateTabRelative(1),
		},
    {
      mods="CTRL", 
      key="Tab",
      action="DisableDefaultAssignment"
    },
    {
      mods="CTRL|SHIFT", 
      key="Tab",
      action="DisableDefaultAssignment"
    },
    -- {
    --   mods="CMD", 
    --   key="w",
    --   action="DisableDefaultAssignment"
    -- },
    -- {
    --   mods="CTRL", 
    --   key="q",
    --   action= action.CloseCurrentPane { confirm = false }
    -- },
	}
end

return M
