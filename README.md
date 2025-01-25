# tips.nvim

🎉 **Bring tips to your Neovim setup!**

Want to learn new tricks or improve your workflow? `tips.nvim` lets you display helpful tips in a
floating window — perfect for startup motivation or practice reminders. And don’t worry, this also
includes the most important feature of startup tips: You can turn them off. Simply adjust your
config to not load them 🤣

## Features

- Provide tips as a Markdown string. Each `#` starts a new tip.
- Show a random tip with a single function call.
- Fully configurable! Decide when and how tips appear — see the example below.
- Note: This plugin does not include any tips. You should write your own.

## Motivation

**The best way to use this plugin is to not need it.**

I created `tips.nvim` to help me remember movement patterns I tend to forget or underuse. My tips
file is intentionally small—just a few key reminders. Once a tip becomes second nature, I remove it
from the file.

## Installation

Below, you can see an example configuration that shows a startup tip on the first start of Neovim
each day. This exmaple assumes you use `lazy.nvim`. Adjust to your needs:

```lua
{
  'rene-hess/tip.nvim',
  config = function()
    -- Read tips from a markdown file next to this file
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
        width = 0.8,
        height = 0.8,
        border = 'rounded',
      },
    }

    -- Show tip on startup (alternative: define a keybinding or do something else)
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        local last_shown = require('tip').last_shown()

        -- Show startup tip if no tip was shown yet
        if not last_shown then
          require('tip').show_tip()
          return
        end

        -- Show startup tip if last time a tip was shown was not today. Adjust to your needs.
        local last_shown_date = os.date('*t', last_shown)
        local current_date = os.date '*t'
        if last_shown_date.year == current_date.year and last_shown_date.month == current_date.month and last_shown_date.day == current_date.day then
          vim.notify('Do not show startup tip. Last tip was shown at ' .. os.date('%Y-%m-%d %H:%M:%S', last_shown), vim.log.levels.INFO)
        else
          require('tip').show_tip()
        end
      end,
    })
  end,
}
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
