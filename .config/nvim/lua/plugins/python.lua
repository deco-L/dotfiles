if false then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "ninja",
        "rst",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.ruff = vim.tbl_deep_extend("force", opts.servers.ruff or {}, {
        cmd_env = { RUFF_TRACE = "messages" },
        init_options = {
          settings = {
            logLevel = "error",
          },
        },
        keys = {
          {
            "<leader>co",
            LazyVim.lsp.action["source.organizeImports"],
            desc = "Organize Imports",
          },
        },
      })
      opts.servers.ruff_lsp = vim.tbl_deep_extend("force", opts.servers.ruff_lsp or {}, {
        keys = {
          {
            "<leader>co",
            LazyVim.lsp.action["source.organizeImports"],
            desc = "Organize Imports",
          },
        },
      })
      opts.setup = opts.setup or {}
      opts.setup.ruff = function()
        LazyVim.lsp.on_attach(function(client, _)
          client.server_capabilities.hoverProvider = false
        end, "ruff")
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      local servers = { "pyright", "basedpyright", "ruff", "ruff_lsp", "lsp" }
      for _, server in ipairs(servers) do
        opts.servers[server] = opts.servers[server] or {}
        opts.servers[server].enabled = true
      end
    end,
  },

  {
    "nvim-neotest/neotest-python",
  },

  -- {
  --   "mfussenegger/nvim-dap-python",
  --   keys = {
  --     {
  --       "<leader>dPt",
  --       function()
  --         require("dap-python").test_method()
  --       end,
  --       desc = "Debug Method",
  --       ft = "python",
  --     },
  --     {
  --       "<leader>dPc",
  --       function()
  --         require("dap-python").test_class()
  --       end,
  --       desc = "Debug Class",
  --       ft = "python",
  --     },
  --   },
  --   config = function()
  --     if vim.fn.has("win32") == 1 then
  --       require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe"))
  --     else
  --       require("dap-python").setup(LazyVim.get_pkg_path("debugpy", "/venv/bin/python"))
  --     end
  --   end,
  -- },

  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}

      if type(opts.adapters) == "table" and not vim.islist(opts.adapters) then
        opts.adapters["neotest-python"] = vim.tbl_deep_extend("force", opts.adapters["neotest-python"] or {}, {
          -- runner = "pytest",
          -- python = ".venv/bin/python",
        })
      end
    end,
  },

  -- {
  --   "mfussenegger/nvim-dap",
  --   optional = true,
  --   dependencies = {
  --     {
  --       "mfussenegger/nvim-dap-python",
  --       config = function()
  --         local path
  --         if vim.fn.has("win64") == 1 then
  --           path = LazyVim.get_pkg_path("debugpy", "/venv/Scripts/pythonw.exe")
  --         else
  --           path = LazyVim.get_pkg_path("debugpy", "/venv/bin/python")
  --         end
  --         require("dap-python").setup(path)
  --       end,
  --       keys = {
  --         {
  --           "<leader>dPt",
  --           function()
  --             require("dap-python").test_method()
  --           end,
  --           desc = "Debug Method",
  --           ft = "python",
  --         },
  --         {
  --           "<leader>dPc",
  --           function()
  --             require("dap-python").test_class()
  --           end,
  --           desc = "Debug Class",
  --           ft = "python",
  --         },
  --       },
  --     },
  --   },
  -- },

  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      opts.auto_brackets = opts.auto_brackets or {}
      table.insert(opts.auto_brackets, "python")
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.handlers = opts.handlers or {}
      opts.handlers.python = function() end
    end,
  },
}
