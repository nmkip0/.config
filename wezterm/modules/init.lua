local term = require("modules.term-workspace")
local keys = require("modules.keybindings")
local tabs = require("modules.tabs")

local M = {}

function M.init(config)
  keys.init(config)
  tabs.init(config)
  term.init(config)
end

return M
