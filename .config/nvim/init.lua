vim.api.nvim_set_var('mapleader', '\\')

-- load lua/
require("core.options")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("core.lazy")

