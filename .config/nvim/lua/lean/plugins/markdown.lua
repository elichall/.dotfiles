return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    keys = {
      {
        "<leader>P",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Toggle Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
      -- Optional: Prevent the preview from automatically closing when you switch buffers
      vim.g.mkdp_auto_close = 0
      -- Explicitly set Zen browser
      vim.g.mkdp_browser = "zen-browser"
    end,
  },
}
