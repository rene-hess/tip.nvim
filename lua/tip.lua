local M = {}

local default_layout = {
  width = 0.8,
  height = 0.8,
  border = "rounded",
}

local state = {
  tips = nil,
  layout = {},
  _setup_done = false,
}

local function get_script_dir()
  local info = debug.getinfo(1, "S")
  local script_path = info.source:sub(2)
  return vim.fn.fnamemodify(script_path, ":h")
end

M.setup = function(opts)
  opts = opts or {}

  if opts.tips == nil then
    local script_dir = get_script_dir()
    local file = io.open(script_dir .. "/default.md", "r")
    local default_tips = ""
    if file then
      default_tips = file:read("*a")
      file:close()
    else
      default_tips = "Error: Could not read default tips."
    end
    opts.tips = default_tips
  end
  state.tips = opts.tips

  state.layout = vim.tbl_extend("force", default_layout, opts.layout or {})

  state._setup_done = true
end

local function create_floating_window(cfg, enter)
  if enter == nil then
    enter = false
  end
  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  local win = vim.api.nvim_open_win(buf, enter, cfg)
  return { buf = buf, win = win }
end

local function create_windows()
  local width = vim.o.columns
  local height = vim.o.lines
  local win_width = math.floor(width * state.layout.width)
  local win_height = math.floor(height * state.layout.height)
  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  local title_cfg = {
    relative = "editor",
    width = win_width,
    height = 1,
    style = "minimal",
    border = "rounded",
    row = row + 1,
    col = col,
  }
  local title = create_floating_window(title_cfg, false)

  local cfg = {
    relative = "editor",
    width = win_width,
    height = win_height - 3,
    style = "minimal",
    border = state.layout.border,
    row = row + 4,
    col = col,
  }
  local body = create_floating_window(cfg, true)

  return { title = title, body = body }
end

local function parse(content)
  local lines = vim.split(content, "\n")

  local tips = {}
  local current_tip = {
    title = "",
    body = {},
  }

  local separator = "^#"
  for _, line in ipairs(lines) do
    if line:find(separator) then
      if #current_tip.title > 0 then
        table.insert(tips, current_tip)
      end

      current_tip = {
        title = line,
        body = {},
      }
    else
      table.insert(current_tip.body, line)
    end
  end
  table.insert(tips, current_tip)

  return tips
end

local function set_body_content(float, tips)
  vim.bo[float.buf].filetype = "markdown"

  local parsed_tips = parse(tips)
  local number = math.random(#parsed_tips)

  -- NOTE: A bit stupid to first separate the title and then join it again. I'm not yet sure if
  -- I want to do something fancy.
  local tip_with_title = { parsed_tips[number].title }
  for _, line in ipairs(parsed_tips[number].body) do
    table.insert(tip_with_title, line)
  end

  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, tip_with_title)
end

local function set_title_content(float)
  vim.bo[float.buf].filetype = "markdown"

  local width = vim.api.nvim_win_get_width(float.win)
  local title = "# Startup Tips"
  local padding = string.rep(" ", (width - #title) / 2)
  title = padding .. title
  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, { title })
end

local function add_keymaps(float)
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(float.win, true)
  end, { buffer = float.buf })
end

local function add_autocmds(windows)
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = windows.body.buf,
    callback = function()
      pcall(vim.api.nvim_win_close, windows.title.win, true)
    end,
  })
end

M.show_tip = function()
  if not state._setup_done then
    error("Tip: setup() must be called before show_tip().")
  end

  local windows = create_windows()
  add_autocmds(windows)

  set_body_content(windows.body, state.tips)
  set_title_content(windows.title)
  add_keymaps(windows.body)
end

return M
