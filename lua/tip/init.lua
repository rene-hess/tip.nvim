local config = require("tip.config")
local show = require("tip.show")

local M = {}

M.setup = config.setup
M.show_tip = show.show_tip

return M
