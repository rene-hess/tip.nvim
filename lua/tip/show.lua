local config = require("tip.config")
local path = require("plenary.path")

local M = {}

---@class tip.Winbuf
---@field buf number: The buffer number
---@field win number: The window number

---@param cfg vim.api.keyset.win_config Map defining the window configuration
---@param enter boolean: Whether to enter the window
---@return tip.Winbuf: The buffer and window number
local function create_floating_winbuf(cfg, enter)
  if enter == nil then
    enter = false
  end
  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  local win = vim.api.nvim_open_win(buf, enter, cfg)
  return { buf = buf, win = win }
end

---@class tip.Winbufs
---@field title tip.Winbuf: The title window
---@field body tip.Winbuf: The body window
---@field footer tip.Winbuf: The footer window

---@return tip.Winbufs: The title, body, and footer window
local function create_winbufs()
  local width = vim.o.columns
  local height = vim.o.lines
  local win_width = math.floor(width * config.options.layout.width)
  local win_height = math.floor(height * config.options.layout.height)
  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  local border_correction = 1
  if config.options.layout.border == "none" then
    border_correction = 0
  end

  local title_cfg = {
    relative = "editor",
    width = win_width,
    height = 1,
    style = "minimal",
    border = config.options.layout.border,
    row = row + border_correction,
    col = col,
  }
  local title = create_floating_winbuf(title_cfg, false)

  local body_cfg = {
    relative = "editor",
    width = win_width,
    height = win_height - 2 - 6 * border_correction,
    style = "minimal",
    border = config.options.layout.border,
    row = row + 1 + 3 * border_correction,
    col = col,
  }
  local body = create_floating_winbuf(body_cfg, true)

  local footer_cfg = {
    relative = "editor",
    width = win_width,
    height = 1,
    style = "minimal",
    border = config.options.layout.border,
    row = row + win_height - 1 - border_correction,
    col = col,
  }
  local footer = create_floating_winbuf(footer_cfg, false)

  return { title = title, body = body, footer = footer }
end

---@class tip.Tip
---@field title string: The title of the tip
---@field body table: The body of the tip

---@param tips string: Markdown where each `#` is a tip
---@return tip.Tip[]: A list of tips
local function parse(tips)
  local lines = vim.split(tips, "\n")

  local parsed_tips = {}
  local current_tip = {
    title = "",
    body = {},
  }

  local separator = "^#"
  for _, line in ipairs(lines) do
    if line:find(separator) then
      if #current_tip.title > 0 then
        table.insert(parsed_tips, current_tip)
      end

      current_tip = {
        title = line,
        body = {},
      }
    else
      table.insert(current_tip.body, line)
    end
  end
  table.insert(parsed_tips, current_tip)

  return parsed_tips
end

---@param winbuf tip.Winbuf: The floating window buffer
---@param tips string: Markdown where each `#` is a tip
local function set_body_content(winbuf, tips)
  vim.bo[winbuf.buf].filetype = "markdown"

  local parsed_tips = parse(tips)
  local number = math.random(#parsed_tips)

  local tip_with_title = { parsed_tips[number].title }
  for _, line in ipairs(parsed_tips[number].body) do
    table.insert(tip_with_title, line)
  end

  vim.api.nvim_buf_set_lines(winbuf.buf, 0, -1, false, tip_with_title)
end

---@param winbuf tip.Winbuf: The floating window buffer
local function set_title_content(winbuf)
  vim.bo[winbuf.buf].filetype = "markdown"

  local width = vim.api.nvim_win_get_width(winbuf.win)
  local text = "# Startup Tips"
  local padding = string.rep(" ", (width - #text) / 2)
  text = padding .. text
  vim.api.nvim_buf_set_lines(winbuf.buf, 0, -1, false, { text })
end

---@param winbuf tip.Winbuf: The floating window buffer
local function set_footer_content(winbuf)
  vim.bo[winbuf.buf].filetype = "markdown"

  local width = vim.api.nvim_win_get_width(winbuf.win)
  local text = "Press `q` to close tip."
  local padding = string.rep(" ", (width - #text) / 2)
  text = padding .. text
  vim.api.nvim_buf_set_lines(winbuf.buf, 0, -1, false, { text })
end

---@param winbuf tip.Winbuf: The floating window buffer
local function add_keymaps(winbuf)
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(winbuf.win, true)
  end, { buffer = winbuf.buf })
end

---@param windows tip.Winbufs: A table of window buffers
---@param callback fun(name: string, window: tip.Winbuf): any  The callback function
local function foreach_window(windows, callback)
  for name, window in pairs(windows) do
    callback(name, window)
  end
end

---Add an autocmd to close the floating windows when the buffer is closed
---@param windows tip.Winbufs: A table of window buffers
local function add_autocmds(windows)
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = windows.body.buf,
    callback = function()
      local callback = function(_, window)
        pcall(vim.api.nvim_win_close, window.win, true)
      end
      foreach_window(windows, callback)
    end,
  })
end

-- Get the directory of this script
local function get_script_dir()
  local info = debug.getinfo(1, "S")
  local script_path = info.source:sub(2)
  return vim.fn.fnamemodify(script_path, ":h")
end

local function read_file(path)
  local file, err = io.open(path, "r")
  if not file then
    return nil, err
  end
  local content = file:read("*a")
  file:close()
  return content
end

local function set_buffer_options(buf)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
end

local function save_last_shown_time()
  local data_path = path:new(vim.fn.stdpath("data"), "tip-nvim")
  data_path:mkdir({ parents = true })

  local time_file = data_path:joinpath("last_shown.txt")
  local current_time = tostring(os.time())
  time_file:write(current_time, "w")
end

M.show_tip = function()
  local options = config.options

  if options.tips == "" then
    local script_dir = get_script_dir()
    local default_tips, err = read_file(script_dir .. "/default.md")
    if not default_tips then
      default_tips = "Error: Could not read default tips" .. err
    end
    options.tips = default_tips
  end

  local windows = create_winbufs()

  add_autocmds(windows)
  add_keymaps(windows.body)

  set_body_content(windows.body, config.options.tips)
  set_title_content(windows.title)
  set_footer_content(windows.footer)

  for _, buf in pairs({ windows.title.buf, windows.body.buf, windows.footer.buf }) do
    set_buffer_options(buf)
  end

  save_last_shown_time()
end

---@return number|nil timestamp: Unix timestamp of when the last tip was shown, or nil if never shown
M.last_shown = function()
  local data_path = path:new(vim.fn.stdpath("data"), "tip-nvim")
  local time_file = data_path:joinpath("last_shown.txt")
  local last_shown_time = time_file:read()
  return last_shown_time
end

-- Only exprted for testing
M._parse = parse

return M
