return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost" },
    cmd = { "LspInfo", "LspInstall", "LspUninstall", "Mason" },
    dependencies = {
      -- Plugin(s) and UI to automatically install LSPs to stdpath
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Install lsp autocompletions
      "hrsh7th/cmp-nvim-lsp",

      -- Progress/Status update for LSP
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Default handlers for LSP
      local default_handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
      }

      local ts_ls_inlay_hints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP Specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- LSP servers to install (see list here: https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers )
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- LSP Servers
        bashls = {},
        cssls = {},
        eslint = {
          autostart = false,
          cmd = { "vscode-eslint-language-server", "--stdio", "--max-old-space-size=12288" },
          settings = {
            format = false,
          },
        },
        html = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                -- Tells lua_ls where to find all the Lua files that you have loaded
                -- for your neovim configuration.
                library = {
                  "${3rd}/luv/library",
                  unpack(vim.api.nvim_get_runtime_file("", true)),
                },
              },
              telemetry = { enabled = false },
            },
          },
        },
        sqlls = {},
        tailwindcss = {},
        ts_ls = {
          settings = {
            maxts_lsMemory = 12288,
            typescript = {
              inlayHints = ts_ls_inlay_hints,
            },
            javascript = {
              inlayHints = ts_ls_inlay_hints,
            },
          },
        },
      }

      local formatters = {
        prettierd = {},
        stylua = {},
      }

      local mason_tools_to_install = vim.tbl_keys(vim.tbl_deep_extend("force", {}, servers, formatters))

      require("mason-tool-installer").setup({
        auto_update = true,
        run_on_start = true,
        start_delay = 3000,
        debounce_hours = 12,
        ensure_installed = mason_tools_to_install,
      })

      -- Iterate over our servers and set them up
      for name, config in pairs(servers) do
        require("lspconfig")[name].setup({
          autostart = config.autostart,
          cmd = config.cmd,
          capabilities = capabilities,
          filetypes = config.filetypes,
          handlers = vim.tbl_deep_extend("force", {}, default_handlers, config.handlers or {}),
          settings = config.settings,
          root_dir = config.root_dir,
        })
      end

      -- Setup mason so it can manage 3rd party LSP servers
      require("mason").setup({
        ui = {
          border = "rounded",
        },
      })

      require("mason-lspconfig").setup()

      -- Configure borderd for LspInfo ui
      require("lspconfig.ui.windows").default_options.border = "rounded"

      -- Configure diagnostics border
      vim.diagnostic.config({
        float = {
          border = "rounded",
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      notify_on_error = false,
      default_format_opts = {
        async = true,
        timeout_ms = 500,
        lsp_format = "fallback",
      },
      format_after_save = {
        async = true,
        timeout_ms = 500,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        typescriptreact = { "prettiered", "prettier" },
        lua = { "stylua" },
      },
    },
  },
}
