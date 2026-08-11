-- 背景を全部透過させて wezterm の window_background_opacity (0.85) を活かす。
-- colorscheme は LazyVim 既定の tokyonight-moon。
--
-- 透過の濃度は nvim 側では持てない(背景色を塗るか塗らないかの二択)。
-- 薄すぎる/濃すぎるときは wezterm の window_background_opacity を触る。
return {
  "folke/tokyonight.nvim",
  opts = {
    transparent = true, -- 通常ウィンドウの背景色を設定しない
    styles = {
      sidebars = "transparent", -- neo-tree など
      floats = "transparent", -- 補完・hover
    },

    -- 透過すると背景が壁紙になり、暗い前景色が沈んで読めなくなる。
    -- 元の値より明るくしてコントラストを稼ぐ(色相は元のまま)。
    on_colors = function(colors)
      colors.fg = "#d5dcf7" -- 元 #c8d3f5 本文
      colors.fg_dark = "#a9b2dc" -- 元 #828bb8
      colors.fg_sidebar = "#a9b2dc" -- 元 #828bb8 neo-tree のファイル名
      colors.comment = "#8b95cc" -- 元 #636da6 コメント
      colors.dark3 = "#7a83a8" -- 元 #545c7e 行番号・薄い文字
      colors.dark5 = "#8f97c0" -- 元 #737aa2
    end,

    -- 行番号は fg_gutter(#3b4261) 由来でとりわけ暗い。ただし fg_gutter は
    -- Folded / PmenuSel / PmenuThumb の「背景」にも使われるため色自体は変えず、
    -- 行番号のグループだけ上書きする。
    on_highlights = function(hl, c)
      local gutter = "#6b7396"
      hl.LineNr = { fg = gutter }
      hl.LineNrAbove = { fg = gutter }
      hl.LineNrBelow = { fg = gutter }
      hl.SignColumn = { fg = gutter, bg = c.none }
    end,
  },
}
