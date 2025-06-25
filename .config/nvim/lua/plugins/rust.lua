if false then
  return {}
end

return {
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = function(_, opts)
      opts = opts or {}
      opts.completion = opts.completion or {}
      opts.completion.creates = opts.completion.creates or {}
      opts.completion.creates.enabled = true
      opts.lsp = opts.lsp or {}
      opts.lsp.enabled = true
      opts.lsp.actions = true
      opts.lsp.completion = true
      opts.lsp.hover = true
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts = opts or {}
      vim.list_extend(opts.ensure_installed, {
        "rust",
        "ron",
      })
    end,
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
    opts = function(_, opts)
      opts.server = opts.server or {}

      local user_on_attach = opts.server.on_attach
      opts.server.on_attach = function(client, bufnr)
        if user_on_attach then
          user_on_attach(client, bufnr)
        end

        vim.keymap.set("n", "<leader>cR", function()
          vim.cmd.RustLsp("codeAction")
        end, { desc = "Code Action", buffer = bufnr })

        vim.keymap.set("n", "<leader>dr", function()
          vim.cmd.RustLsp("debuggables")
        end, { desc = "Rust Debuggables", buffer = bufnr })
      end

      opts.server.default_settings = vim.tbl_deep_extend("force", opts.server.default_settings or {}, {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = { enable = true },
          },
          checkOnSave = true,
          diagnostics = {
            enable = true,
          },
          procMacro = {
            enable = true,
            ignored = {
              ["async-trait"] = { "async_trait" },
              ["napi-derive"] = { "napi" },
              ["async-recursion"] = { "async_recursion" },
            },
          },
          files = {
            excludeDirs = {
              ".direnv",
              ".git",
              ".github",
              ".gitlab",
              "bin",
              "node_modules",
              "target",
              "venv",
              ".venv",
            },
          },
        },
      })

      return opts
    end,

    config = function(_, opts)
      if LazyVim.has("mason.nvim") then
        local ok, registry = pcall(require, "mason-registry")
        if ok and registry.has_package("codelldb") then
          local package_path = registry.get_package("codelldb"):get_install_path()
          local codelldb = package_path .. "/extension/adapter/codelldb"
          local library_path = package_path .. "/extension/lldb/lib/liblldb.dylib"
          local uname = io.popen("uname"):read("*l")
          if uname == "Linux" then
            library_path = package_path .. "/extension/lldb/lib/liblldb.so"
          end
          opts.dap = {
            adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
          }
        else
          LazyVim.error("**codelldb** not found.")
        end
      end

      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})

      if vim.fn.executable("rust-analyzer") == 0 then
        LazyVim.error(
          "**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/",
          { title = "rustaceanvim" }
        )
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts = opts or {}
      opts.servers = opts.servers or {}
      opts.servers.rust_analyzer = opts.servers.rust_analyzer or {}
      opts.servers.rust_analyzer.enabled = true
    end,
  },

  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "codelldb",
        "rust-analyzer",
      })
    end,
  },

  {
    "nvim-neotest/neotest",
    optional = true,
    opts = {
      adapters = {
        ["rustaceanvim.neotest"] = {},
      },
    },
  },
}
