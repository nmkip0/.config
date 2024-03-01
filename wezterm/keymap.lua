local wezterm = require 'wezterm'
local M = {}

function M.setup(config) 
  -- keys
  local act = wezterm.action
  config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
  config.keys = {
    -- Send C-a when pressing C-a twice
    { key = "a", mods = "LEADER",       action = act.SendKey { key = "a", mods = "CTRL" } },
    { key = "c", mods = "LEADER",       action = act.ActivateCopyMode },
    { key = "phys:Space", mods = "LEADER",      action = act.ActivateCommandPalette },
    -- Pane keybindings
    { key = "s", mods = "LEADER",       action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = "v", mods = "LEADER",       action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "h", mods = "LEADER",       action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER",       action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER",       action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER",       action = act.ActivatePaneDirection("Right") },
    { key = "q", mods = "LEADER",       action = act.CloseCurrentPane { confirm = true } },
    { key = "p", mods = "LEADER",       action = act.PaneSelect },
    { key = "z", mods = "LEADER",       action = act.TogglePaneZoomState },

    { key = "Q", mods = "CTRL|SHIFT",   action = act.QuitApplication },

    -- { key = "p", mods = "LEADER",       action = act.ActivateKeyTable { name = "move_pane", one_shot = false } },
    { key = "o", mods = "LEADER",       action = act.ActivateKeyTable { name = "rotate_pane", one_shot = false } },
    { key = "r", mods = "LEADER",       action = act.ActivateKeyTable { name = "resize_pane", one_shot = false } },

    -- Tab keybindings
    { key = "n", mods = "LEADER",       action = act.SpawnTab("CurrentPaneDomain") },
    { key = "[", mods = "LEADER",       action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "LEADER",       action = act.ActivateTabRelative(1) },
    { key = "t", mods = "LEADER",       action = act.ShowTabNavigator },
    -- Key table for moving tabs around
    { key = "m", mods = "LEADER",       action = act.ActivateKeyTable { name = "move_tab", one_shot = false } },

    -- Lastly, workspace
    { key = "w", mods = "LEADER",       action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" } },

    {
      key = 'W',
      mods = 'CTRL|SHIFT',
      action = act.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = 'Bold' } },
          { Foreground = { AnsiColor = 'Fuchsia' } },
          { Text = 'Enter name for new workspace' },
        },
        action = wezterm.action_callback(function(window, pane, line)
          -- line will be `nil` if they hit escape without entering anything
          -- An empty string if they just hit enter
          -- Or the actual line of text they wrote
          if line then
            window:perform_action(
              act.SwitchToWorkspace {
                name = line,
              },
              pane
            )
          end
        end),
      },
    },
  }

  for i = 1, 9 do
    table.insert(config.keys, {
      key = tostring(i),
      mods = "CTRL",
      action = act.ActivateTab(i - 1)
    })
  end

  config.key_tables = {
    rotate_pane = {
      { key = "j",      action = act.RotatePanes "Clockwise" },
      { key = "k",      action = act.RotatePanes "CounterClockwise" },
      { key = "Escape", action = "PopKeyTable" },
      { key = "Enter",  action = "PopKeyTable" },
    },
    resize_pane = {
      { key = "h",      action = act.AdjustPaneSize { "Left", 1 } },
      { key = "j",      action = act.AdjustPaneSize { "Down", 1 } },
      { key = "k",      action = act.AdjustPaneSize { "Up", 1 } },
      { key = "l",      action = act.AdjustPaneSize { "Right", 1 } },
      { key = "Escape", action = "PopKeyTable" },
      { key = "Enter",  action = "PopKeyTable" },
    },
    move_pane = {
      { key = "h", action = act.ActivatePaneDirection("Left") },
      { key = "j", action = act.ActivatePaneDirection("Down") },
      { key = "k", action = act.ActivatePaneDirection("Up") },
      { key = "l", action = act.ActivatePaneDirection("Right") },
      { key = "Escape", action = "PopKeyTable" },
      { key = "Enter",  action = "PopKeyTable" },
    },
    move_tab = {
      { key = "h",      action = act.MoveTabRelative(-1) },
      { key = "j",      action = act.MoveTabRelative(-1) },
      { key = "k",      action = act.MoveTabRelative(1) },
      { key = "l",      action = act.MoveTabRelative(1) },
      { key = "Escape", action = "PopKeyTable" },
      { key = "Enter",  action = "PopKeyTable" },
    }
  }
end

return M 
