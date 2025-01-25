local config = require("tip.config")
local show = require("tip.show")

local M = {}

M.setup = config.setup
M.show_tip = show.show_tip
M.last_shown = show.last_shown

return M
