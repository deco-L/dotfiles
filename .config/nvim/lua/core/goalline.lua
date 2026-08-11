-- colorcolumn の横版: 目標行に色を敷く
-- extmark はバッファ位置に付くのでスクロールすれば一緒に流れる。
-- 行番号は絶対値で固定するので、上に行を挿入しても目標はずれない（行数の目標として使える）。

local ns = vim.api.nvim_create_namespace("goalline")

---@type table<integer, integer> bufnr -> 目標行(1-indexed)
local targets = {}

vim.api.nvim_set_hl(0, "GoalLine", { default = true, link = "Visual" })
vim.api.nvim_set_hl(0, "GoalLineNr", { default = true, link = "WarningMsg" })

local function redraw(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  local lnum = targets[buf]
  if not lnum then
    return
  end
  -- まだ目標行まで届いていないバッファには何も出さない
  if lnum > vim.api.nvim_buf_line_count(buf) then
    return
  end

  vim.api.nvim_buf_set_extmark(buf, ns, lnum - 1, 0, {
    line_hl_group = "GoalLine",
    number_hl_group = "GoalLineNr",
    virt_text = { { "  ← goal " .. lnum, "GoalLineNr" } },
    virt_text_pos = "eol",
  })
end

---@type table<integer, boolean>
local attached = {}

-- TextChanged は API 経由の変更では発火せず extmark がテキストごと流れてしまうので、
-- on_lines で全ての変更を拾って絶対行に貼り直す。
local function attach(buf)
  if attached[buf] then
    return
  end
  attached[buf] = true
  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      if not targets[buf] then
        attached[buf] = nil
        return true -- detach
      end
      vim.schedule(function()
        redraw(buf)
      end)
    end,
    on_detach = function()
      attached[buf] = nil
    end,
  })
end

local function set(buf, lnum)
  targets[buf] = lnum
  attach(buf)
  redraw(buf)
end

local function clear(buf)
  targets[buf] = nil
  redraw(buf)
end

vim.api.nvim_create_user_command("GoalLine", function(opts)
  local buf = vim.api.nvim_get_current_buf()
  if opts.bang then
    clear(buf)
    return
  end
  local lnum = tonumber(opts.args)
  if lnum == 0 then
    clear(buf)
  elseif lnum and lnum > 0 then
    set(buf, math.floor(lnum))
  else
    set(buf, vim.fn.line("."))
  end
end, {
  nargs = "?",
  bang = true,
  desc = "目標行に色を敷く (:GoalLine 100 / :GoalLine で現在行 / :GoalLine! で解除)",
})

-- LazyVim のキーマップは VeryLazy 以降に設定され、init.lua の時点で登録すると
-- 上書きされうる。VeryLazy 後に登録する。
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    vim.keymap.set("n", "<leader>uo", function()
      local buf = vim.api.nvim_get_current_buf()
      local lnum = vim.fn.line(".")
      if targets[buf] == lnum then
        clear(buf)
      else
        set(buf, lnum)
      end
    end, { desc = "Toggle Goal Line (現在行)" })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("goalline_redraw", { clear = true }),
  callback = function(ev)
    if targets[ev.buf] then
      redraw(ev.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("goalline_hl", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "GoalLine", { default = true, link = "Visual" })
    vim.api.nvim_set_hl(0, "GoalLineNr", { default = true, link = "WarningMsg" })
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  group = vim.api.nvim_create_augroup("goalline_cleanup", { clear = true }),
  callback = function(ev)
    targets[ev.buf] = nil
  end,
})
