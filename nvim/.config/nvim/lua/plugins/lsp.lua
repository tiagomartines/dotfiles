local servers = {
  "lua_ls",
  "ts_ls",
}

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = {
      automatic_enable = false,
      ensure_installed = servers,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = {
      ensure_installed = {
        "stylua",
        "prettierd",
      },
      run_on_start = true,
      start_delay = 0,
      debounce_hours = 24,
    },
  },
  {
    "Saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = {
        preset = "default",
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
      },
      signature = {
        enabled = true,
      },
      snippets = {
        preset = "default",
      },
      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
        },
      },
      cmdline = {
        keymap = {
          preset = "cmdline",
        },
        completion = {
          menu = {
            auto_show = true,
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "Saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.diagnostic.config({
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(lhs, rhs, desc, mode)
            vim.keymap.set(mode or "n", lhs, rhs, { buffer = event.buf, desc = desc })
          end

          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gr", vim.lsp.buf.references, "Goto references")
          map("gI", vim.lsp.buf.implementation, "Goto implementation")
          map("K", vim.lsp.buf.hover, "Hover")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
          map("]d", vim.diagnostic.goto_next, "Next diagnostic")
        end,
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
            },
          },
        },
      })

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
      })

      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({
            async = true,
            lsp_format = "fallback",
          })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        lua = { "stylua" },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_format = "never",
      },
      notify_on_error = true,
    },
  },
}
