local M = {}

local function spawn_terminal_window(cb)
	local cmd = "/opt/homebrew/bin/wezterm"
	local args = { "start", "--always-new-process", "--workspace", "term" }
	local task = hs.task.new(cmd, nil, args)

	local watcher
	watcher = hs.application.watcher.new(function(_, event, app)
		if event ~= hs.application.watcher.launched then
			return
		end

		if app:pid() ~= task:pid() then
			return
		end

		watcher:stop()
		cb(app)
	end)

	watcher:start()
	task:start()
end

local application_pid
local function with_term(cb)
	if application_pid then
		local app = hs.application.applicationForPID(application_pid)
		if app then
			return cb(app)
		end
	end

	spawn_terminal_window(function(app)
		application_pid = app:pid()
		cb(app)
	end)
end

function M.init()
	hs.hotkey.bind({ "Ctrl" }, "`", function()
		with_term(function(term)
			if term:isFrontmost() then
				term:hide()
				return
			end

			local wez_window = term:mainWindow()
			local target_screen = hs.mouse.getCurrentScreen()

			wez_window:moveToScreen(target_screen)
			wez_window:maximize(0)
			wez_window:focus()
		end)
	end)
end

return M
