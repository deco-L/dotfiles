if true then
  return {}
end

return {
  -- 1. LazyVim公式のCopilot設定をまるごと読み込む（超重要）
  { import = "lazyvim.plugins.extras.ai.copilot" },
  { import = "lazyvim.plugins.extras.ai.copilot-chat" },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = { model = "gpt-5.2-codex" },
  },
  -- 2. 元々書いていたTreesitterの設定
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

  -- 3. 元々書いていたcmp-gitの設定
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
