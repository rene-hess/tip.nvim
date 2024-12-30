# Create Your own Tips

You should create your own tips and call the `setup` function. Tips should be a string
with Markdown, where each section `#` is a tip. Below is an example that reads tips
from a file.

```lua
return {
  {
    dir = '~/path/to/tip.nvim',
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
          border = 'solid',
        },
      }

      -- Show tip on startup
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          require('tip').show_tip()
        end,
      })
    end,
  },
}
```
