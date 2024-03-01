local wezterm = require("wezterm")
local colors = require("theme").get_colors()

local M = {}

local basename = function(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function format_process(process_name)
  local process_icons = {
    ["docker"] = {
      { Foreground = { Color = colors.blue } },
      { Text = "󰡨" },
    },
    ["docker-compose"] = {
      { Foreground = { Color = colors.blue } },
      { Text = "󰡨" },
    },
    ["nvim"] = {
      { Foreground = { Color = colors.green } },
      { Text = "" },
    },
    ["bob"] = {
      { Foreground = { Color = colors.blue } },
      { Text = "" },
    },
    ["vim"] = {
      { Foreground = { Color = colors.green } },
      { Text = "" },
    },
    ["node"] = {
      { Foreground = { Color = colors.green } },
      { Text = "󰋘" },
    },
    ["zsh"] = {
      { Foreground = { Color = colors.peach } },
      { Text = "" },
    },
    ["bash"] = {
      { Foreground = { Color = colors.overlay1 } },
      { Text = "" },
    },
    ["htop"] = {
      { Foreground = { Color = colors.yellow } },
      { Text = "" },
    },
    ["cargo"] = {
      { Foreground = { Color = colors.peach } },
      { Text = wezterm.nerdfonts.dev_rust },
    },
    ["git"] = {
      { Foreground = { Color = colors.peach } },
      { Text = "󰊢" },
    },
    ["lua"] = {
      { Foreground = { Color = colors.blue } },
      { Text = "" },
    },
    ["wget"] = {
      { Foreground = { Color = colors.yellow } },
      { Text = "󰄠" },
    },
    ["curl"] = {
      { Foreground = { Color = colors.yellow } },
      { Text = "" },
    },
    ["gh"] = {
      { Foreground = { Color = colors.mauve } },
      { Text = "" },
    },
  }

  if process_icons[process_name] then
    return wezterm.format(process_icons[process_name])
  elseif process_name == "" then
    return wezterm.format({
      { Foreground = { Color = colors.red } },
      { Text = "󰌾" },
    })
  else
    return wezterm.format({
      { Foreground = { Color = colors.blue } },
      { Text = string.format("[%s]", process_name) },
    })
  end
end

local function get_current_working_folder_name(tab)
  local cwd_uri = tab.active_pane.current_working_dir

  cwd_uri = cwd_uri:sub(8)


  local slash = cwd_uri:find("/")
  local cwd = cwd_uri:sub(slash)

  local HOME_DIR = os.getenv("HOME")
  if cwd == HOME_DIR then
    return " ~"
  end

  return string.format(" %s", string.match(cwd, ".*/([^/]+)/$"))
end

function M.setup(config)
  config.hide_tab_bar_if_only_one_tab = false
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = true
  config.status_update_interval = 1000
  config.tab_max_width = 50

  wezterm.on("update-right-status", function(window, pane)
    -- Workspace name
    local workspace = window:active_workspace()
    local stat = workspace
    -- It's a little silly to have workspace name all the time
    -- Utilize this to display LDR or current key table name
    if window:active_key_table() then stat = window:active_key_table() end
    if window:leader_is_active() then stat = "LEADER" end

    -- Current command (nvim, etc)
    local foreground_process = basename(pane:get_foreground_process_name())
    
    -- Let's add color to one of the components
    window:set_right_status(wezterm.format({
      -- Wezterm has a built-in nerd fonts
      { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
      { Text = " | " },
      { Foreground = { Color = "FFB86C" } },
      { Text = format_process(foreground_process) },
      { Text = " " .. foreground_process },
      "ResetAttributes",
      { Text = " |" },
    }))
  end)

  wezterm.on("format-tab-title", function(tab)
    local is_zoomed = tab.active_pane.is_zoomed

    return wezterm.format({
      { Text = " " },
      { Attribute = { Intensity = "Half" } },
      { Foreground = { Color = colors.overlay1 } },
      { Text = string.format("%s", tab.tab_index + 1) },
      "ResetAttributes",
      { Text = get_current_working_folder_name(tab) },
      { Text = is_zoomed and " Z" or ""},
      { Foreground = { Color = colors.base } },
      { Text = " " },
    })
  end)

end

return M
