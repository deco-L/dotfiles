if false then
  return {}
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.tailwindcss = opts.servers.tailwindcss or {}
      opts.servers.tailwindcss.filetypes_exclude = opts.servers.tailwindcss.filetypes_exclude or { "markdown" }
      opts.servers.tailwindcss.filetypes_include = opts.servers.tailwindcss.filetypes_include or {}
      opts.setup = opts.setup or {}

      opts.setup.tailwindcss = function(_, lsp_opts)
        local tw = LazyVim.lsp.get_raw_config("tailwindcss")
        lsp_opts.filetypes = lsp_opts.filetypes or {}
        vim.list_extend(lsp_opts.filetypes, tw.default_config.filetypes)
        lsp_opts.filetypes = vim.tbl_filter(function(ft)
          return not vim.tbl_contains(opts.servers.tailwindcss.filetypes_exclude or {}, ft)
        end, lsp_opts.filetypes)
        lsp_opts.settings = vim.tbl_deep_extend("force", lsp_opts.settings or {}, {
          tailwindCSS = {
            includeLanguages = {
              elixir = "html-eex",
              eelixir = "html-eex",
              heex = "html-eex",
            },
          },
        })
        vim.list_extend(lsp_opts.filetypes, opts.servers.tailwindcss.filetypes_include or {})
      end
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", opts = {} },
    },
    opts = function(_, opts)
      local format_kinds = opts.formatting.format
      opts.formatting.format = function(entry, item)
        format_kinds(entry, item)
        return require("tailwindcss-colorizer-cmp").formatter(entry, item)
      end
    end,
  },
}
