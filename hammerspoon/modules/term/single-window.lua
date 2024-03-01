local M = {}

-- A simple keybinding to show and hide the Wezterm application. This only works when
-- using a single wezterm window as the primary terminal. If you want to use other
-- Wezterm windows that remain open then see the module 'term.multi-window'
function M.init()
	hs.hotkey.bind({ "Ctrl" }, "`", function()
		local wez = hs.application.find("Wezterm")
		if wez then
			if wez:isFrontmost() then
				wez:hide()
			else
				local wez_window = wez:mainWindow()
				local target_screen = hs.mouse.getCurrentScreen()

				wez_window:moveToScreen(target_screen)
				wez_window:maximize(0)
				wez_window:focus()
			end
		end
	end)
end

return M
