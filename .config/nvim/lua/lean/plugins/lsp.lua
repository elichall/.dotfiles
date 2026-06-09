-- lua/lean/plugins/lsp.lua
return {
  -- 1. MASON BINARY MANAGER
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  -- 2. NVIM LSPCONFIG LAYER (Migrated to Core Engine Architecture)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")

      -- ==============================================================================
      -- GLOBAL EVENT BOUNDARY: DECOUPLED BUFFER KEYMAPS
      -- ==============================================================================
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "Initialize universal telemetry binds when server links to buffer",
        callback = function(args)
          local bufnr = args.buf
          local opts = { buffer = bufnr, silent = true }

          opts.desc = "Go to Definition"
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

          opts.desc = "LSP Hover Information"
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

          opts.desc = "List Code Actions"
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

          opts.desc = "Rename Symbol"
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

          opts.desc = "Go to References"
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

          opts.desc = "Show Line Diagnostics"
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
        end,
      })

      -- Target server definitions matching workspace parameters
      local target_servers = {
        "lua_ls",
        "clangd",
        "basedpyright",
        "marksman",
        "texlab",
        "bashls"
      }

      -- System binary installation sync mapping
      mason_lspconfig.setup({
        ensure_installed = target_servers,
        automatic_installation = true,
      })

      -- Custom Configuration Tables for Native Injection
      local custom_configs = {
        ["lua_ls"] = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },
        ["texlab"] = {
          settings = {
            texlab = {
              build = {
                executable = "latexmk",
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                onSave = true,
              },
              forwardSearch = {
                executable = vim.fn.executable("zathura") == 1 and "zathura" or "evince",
                args = { "--synctex-forward", "%l:1:%f", "%p" },
              },
            },
          },
        },
      }

      -- ==============================================================================
      -- NATIVE EXECUTION INITIALIZATION LOOP ($O(N)$ Compilation)
      -- ==============================================================================
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = has_blink and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

      for _, server_name in ipairs(target_servers) do
        local config = custom_configs[server_name] or {}
        config.capabilities = vim.tbl_deep_extend("force", config.capabilities or {}, capabilities)

        -- Use native vim.lsp.config instead of the deprecated nvim-lspconfig framework
        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end
    end,
  },
}
