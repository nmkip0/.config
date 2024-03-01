local wez = require("wezterm")

local modules = require("modules")

local config = wez.config_builder()

config.check_for_updates = false

config.color_scheme = "GruvboxDark"
-- config.color_scheme = "nord"
config.font = wez.font("FiraCode Nerd Font Mono")
config.font_size = 13
config.line_height = 1.2

config.freetype_load_target = "Normal"

config.window_padding = {
	left = 10,
	right = 10,
	top = 0,
	bottom = 0,
}

config.cursor_thickness = "1.5pt"

modules.init(config)

config.colors["cursor_bg"] = "#928374"
config.colors["cursor_border"] = "#928374"
config.colors["split"] = "#928374"

config.underline_thickness = "1.2pt"
config.underline_position = "150%"

config.inactive_pane_hsb = {
	saturation = 0.5,
	brightness = 0.6,
}

--config.term = "wezterm"

return config
