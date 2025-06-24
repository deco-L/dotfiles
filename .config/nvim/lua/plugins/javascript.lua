if true then
  return {}
end

return {
  {
    "echasnovski/mini.icons",
    opts = {
      file = {
        [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
        [".prettierrc.js"] = { glyph = "", hl = "MiniIconsPurple" },
        ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
        ["package-lock.json"] = { glyph = "", hl = "MiniIconsGreen" },
        ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
        [".babelrc"] = { glyph = "󰌵", hl = "MiniIconsPurple" },
        [".babelrc.js"] = { glyph = "󰌵", hl = "MiniIconsPurple" },
      },
    },
  },
}
