local wezterm = require("wezterm")

local M = {}

local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

local gruvbox_dark = {
  tab_bar_bg = "#282828",
  active_tab_bg = "#d79921",
  active_tab_fg = "#3c3836",
  inactive_tab_bg = "#665c54",
  inactive_tab_fg = "#bdae93",
}

local nord = {
  tab_bar_bg = "#2E3440",
  active_tab_bg = "#81A1C1",
  active_tab_fg = "#ECEFF4",
  inactive_tab_bg = "#4C566A",
  inactive_tab_fg = "#D8DEE9",
}

local catpuccin_frappe = {
  tab_bar_bg = "#2E3440",
  active_tab_bg = "#232634",
  active_tab_fg = "#c6d0f5",
  inactive_tab_bg = "#838ba7",
  inactive_tab_fg = "#ECEFF4",
}

function M.init(config)
	config.use_fancy_tab_bar = false
	config.show_tab_index_in_tab_bar = false
	config.show_new_tab_button_in_tab_bar = false
	config.tab_max_width = 50
  --config.tab_bar_at_bottom = true

  local theme = gruvbox_dark

	config.colors = {
		tab_bar = {
			background = theme.tab_bar_bg,
			active_tab = {
				bg_color = theme.active_tab_bg,
				fg_color = theme.active_tab_fg,
			},
			inactive_tab = {
				bg_color = theme.inactive_tab_bg,
				fg_color = theme.inactive_tab_fg,
			},
		},
	}

	wezterm.on("format-tab-title", function(tab, tabs, _panes, _config, _hover, _max_width)
    local is_zoomed = tab.active_pane.is_zoomed
		local title = tab_title(tab)
		title = wezterm.truncate_right(title, config.tab_max_width - 4)

		local icon = wezterm.nerdfonts.pl_left_hard_divider
		local icon_bg
		local icon_fg = theme.inactive_tab_bg

		local next_tab = tabs[tab.tab_index + 2]
		local next_tab_is_active = next_tab and next_tab.is_active
		local is_last_tab = tab.tab_index + 1 == #tabs

		if tab.is_active then
			icon_fg = theme.active_tab_bg
		end

		if is_last_tab then
			icon_bg = theme.tab_bar_bg
		else
			icon_bg = theme.inactive_tab_bg

			if next_tab_is_active then
				icon_bg = theme.active_tab_bg
			end

			if not tab.is_active and not next_tab_is_active then
				icon = wezterm.nerdfonts.pl_left_soft_divider
				icon_fg = theme.inactive_tab_fg
			end
		end

		local intensity = "Normal"
		if tab.is_active then
			intensity = "Bold"
		end

		return {
			{ Attribute = { Intensity = intensity } },
			{ Text = " " .. title .. " " },
      { Text = is_zoomed and "[Z]" or ""},
			{ Background = { Color = icon_bg } },
			{ Foreground = { Color = icon_fg } },
			{ Text = icon },
		}
	end)
end

return M
