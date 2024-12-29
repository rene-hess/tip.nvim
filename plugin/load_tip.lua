vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("tip").show_tip()
  end,
})
