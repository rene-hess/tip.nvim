# tips.nvim

🎉 **Bring tips to your Neovim setup!**

Want to learn new tricks or improve your workflow? `tips.nvim` lets you display helpful tips in a
floating window—perfect for startup motivation or practice reminders. And don’t worry, turning it
off is as easy as a quick config tweak! 🤣

## Features

- Provide tips as a Markdown string. Each `#` starts a new tip.
- Show a random tip with a single function call.
- Fully configurable! Decide when and how tips appear—see the example below.

## Motivation

**The best way to use this plugin is to not need it.**

I created `tips.nvim` to help me remember movement patterns I tend to forget or underuse. My tips
file is intentionally small—just a few key reminders. Once a tip becomes second nature, I remove it
from the file.

## Installation

For `lazy.nvim`, add the following configuration:

```lua
  {
    'rene-hess/tip.nvim',
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
file. See the installation example above.
