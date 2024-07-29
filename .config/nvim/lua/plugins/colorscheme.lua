return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    local tokyonight = require("tokyonight")

    tokyonight.setup({
      style = "moon",
      light_style = "moon",
      transparent = true,
      terminal_colors = true,
      styles = {
        comment = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        --Background styles. Can be "dark", "transparent" or "normal"
        sidebers = "transparent",
        floats = "transparent",
      },
    })
    vim.cmd[[colorscheme tokyonight]]
  end,
}
