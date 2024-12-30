local M = {}

---@class tip.Layout
---@field width? number: Relative width of the floating window
---@field height? number: Relative height of the floating window
---@field border? string: Border style of the floating window

---@class tip.Config
---@field tips? string: Markdown where each `#` is a tip
---@field layout? tip.Layout: The layout of the floating window

---@type tip.Config
local default_options = {
  tips = "",
  layout = {
    width = 0.8,
    height = 0.8,
    border = "rounded",
  },
}

---@type tip.Config
M.options = default_options

---@param opts? tip.Config: Options for the tip module
M.setup = function(opts)
  opts = opts or {}

  M.options = vim.tbl_deep_extend("force", {}, default_options, opts)
end

return M
