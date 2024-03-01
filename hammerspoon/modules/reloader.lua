local M = {}

local function reload_config(files)
	local do_reload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			do_reload = true
		end
	end
	if do_reload then
		hs.reload()
	end
end

function M.init()
	local watcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.config/hammerspoon/", reload_config)
	watcher:start()
end

return M
