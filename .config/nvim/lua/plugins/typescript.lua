if false then
  return {}
end

return {
  -- 1. GitHub Copilot の有効化
  { import = "lazyvim.plugins.extras.coding.copilot" },

  -- 2. TypeScript LSP / ツールの有効化（関数ジャンプもこれで有効になります）
  { import = "lazyvim.plugins.extras.lang.typescript" },

  -- 3. Treesitterの設定（git関連のパーサーを追加）
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

  -- 4. nvim-cmpの設定（git用の補完ソースを追加）
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
