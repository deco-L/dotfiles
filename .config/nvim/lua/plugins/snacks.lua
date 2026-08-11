-- カーソル移動の体感速度を上げる
-- LazyVim の既定はスムーススクロール 200ms/回（snacks/scroll.lua の defaults）。
-- j/k 連打でスクロールが追いつかないので短くする。
-- 完全に切るなら scroll = { enabled = false }。
return {
  "folke/snacks.nvim",
  opts = {
    scroll = {
      animate = {
        duration = { step = 5, total = 60 },
        easing = "linear",
      },
      -- 連続スクロール時はさらに詰める
      animate_repeat = {
        delay = 50,
        duration = { step = 3, total = 20 },
        easing = "linear",
      },
    },

    -- 通知は既定で右上(top_down = true)に出るが、書いているコードに被る。
    -- 下から積めば右下になる(左右の位置は固定で常に右寄せ)。
    notifier = {
      top_down = false,
    },
  },
}
