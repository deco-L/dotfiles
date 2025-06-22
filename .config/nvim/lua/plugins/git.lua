if true then return {} end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "git-config",
        "gitcommit",
        "git_rebase",
        "gitignore",
        "gitattributes",
      })
    end,
  },

  {
    "petertriho/cmp-git",
    opts = {},
  },

  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = {
      { "petertriho/cmp-git" },
    },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "git" })
    end,
  },
}
