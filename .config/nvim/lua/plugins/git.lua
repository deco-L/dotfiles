if false then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "git_config",
        "gitcommit",
        "git_rebase",
        "gitignore",
        "gitattributes",
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      {
        "petertriho/cmp-git",
        config = function()
          require("cmp_git").setup({})
        end,
      },
    },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "git" })
    end,
  },
}
