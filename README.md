# tips.nvim

Yeah! One of the most annoying features brought to Neovim. Tips! If you want they show up on
startup. And since it is your config they are of course easy to turn off 🤣.

- You need to provide a Markdown string. Each section `#` is a tip.
- The plugin provides a function to show a random tip.
- You can configure when to show tips. See the example below.


## Installation

For lazy.nvim use:

```lua
  {
    dir = '~/sync/programming/nvim/tip.nvim',
    config = function()
      -- Read tips from a markdown file next to this file. Each section is a tip.
      local script_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
      local tips_file = script_dir .. '/tips.md'
      if vim.fn.filereadable(tips_file) == 0 then
        print 'Could not open tips file'
        return
      end
      local tips = table.concat(vim.fn.readfile(tips_file), '\n')

      -- Configure tip.nvim
      require('tip').setup {
        tips = tips,
        layout = {
          border = 'solid',
        },
      }

      -- Show tip on startup (alternative: define a keybinding or do something else)
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          require('tip').show_tip()
        end,
      })
    end,
  },
```

## Configuration

```lua
local default_options = {
  tips = "",
  layout = {
    width = 0.8,
    height = 0.8,
    border = "rounded",
  },
}
```
The tips should be provided as a Markdown string. You can, e.g., read the tips from a markdown
file. See installation above.
