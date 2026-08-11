-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.colorcolumn = "80"
vim.o.mouse = ""

-- prettier 設定ファイルがあるリポジトリでだけ prettier を使う。
-- false(既定)だと biome/dprint/eslint だけのリポジトリや設定なしのリポジトリでも
-- prettier の既定ルールで整形され、意図しない差分が出る。
vim.g.lazyvim_prettier_needs_config = true

-- lang
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.list = false
vim.opt.showbreak = ">\\"
