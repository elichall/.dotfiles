local my_theme_group = vim.api.nvim_create_augroup("LanguageThemes", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = my_theme_group,
  callback = function(args)
    vim.schedule(function()
      local buf = args.buf
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      local ft = vim.bo[buf].filetype
      local buftype = vim.bo[buf].buftype

      -- Ignore non-normal buffers (like terminals, help, Telescope, NvimTree, Oil)
      if buftype ~= "" then
        return
      end

      if ft == "markdown" or ft == "tex" or ft == "plaintex" then
        vim.cmd("colorscheme vague")
      elseif ft == "cpp" or ft == "c" then
        vim.cmd("colorscheme vscode_modern")
      elseif ft == "python" then
        vim.cmd("colorscheme dark2026")
      else
        -- Revert to your custom default theme
        vim.cmd("colorscheme lean_sync")
      end
    end)
  end,
})
