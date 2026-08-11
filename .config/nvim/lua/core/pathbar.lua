-- winbar にファイルパスを出し、DDD の層にあたるセグメントだけ色を変える
--
-- lualine の pretty_path は length=3 でパスを truncate するため
-- （lazyvim/util/lualine.lua:126-128）、知りたい層のセグメントが省略される。
-- winbar は横幅が広いので省略せずに出せる。
--
-- <leader>up  表示 ON/OFF
-- <leader>uP  ルート相対 / 絶対パス の切り替え

local M = {}

-- セグメント名（小文字化して比較）→ 層。プロジェクトの命名に合わせてここを足す。
local LAYERS = {}

local function register(layer, names)
  for _, n in ipairs(names) do
    LAYERS[n] = layer
  end
end

register("domain", { "domain", "domains", "entity", "entities", "valueobject", "value_object", "model", "models" })
register("application", { "application", "applications", "app", "usecase", "usecases", "use_case", "use_cases", "service", "services", "interactor" })
register("infrastructure", { "infrastructure", "infrastructures", "infra", "persistence", "repository", "repositories", "adapter", "adapters", "gateway", "gateways", "datasource" })
register("presentation", { "presentation", "interface", "interfaces", "ui", "api", "handler", "handlers", "controller", "controllers", "web", "http", "rest", "graphql", "delivery", "transport", "routes", "router" })
register("shared", { "shared", "common", "kernel", "shared_kernel", "sharedkernel", "pkg", "lib", "utils", "util" })

local HL = {
  domain = "PathbarDomain",
  application = "PathbarApplication",
  infrastructure = "PathbarInfrastructure",
  presentation = "PathbarPresentation",
  shared = "PathbarShared",
}

-- カラースキーム非依存にするため Diagnostic 系にリンクする
local function set_hl()
  local links = {
    PathbarDomain = "DiagnosticOk",
    PathbarApplication = "DiagnosticInfo",
    PathbarInfrastructure = "DiagnosticWarn",
    PathbarPresentation = "DiagnosticHint",
    PathbarShared = "Special",
    PathbarDir = "Comment",
    PathbarSep = "NonText",
  }
  for group, link in pairs(links) do
    vim.api.nvim_set_hl(0, group, { default = true, link = link })
  end
  vim.api.nvim_set_hl(0, "PathbarFile", { default = true, bold = true })
end

set_hl()

local state = {
  enabled = true,
  absolute = false,
}

-- winbar に埋め込む文字列は % をエスケープする
local function esc(s)
  return (s:gsub("%%", "%%%%"))
end

local function hl(group, text)
  return "%#" .. group .. "#" .. esc(text) .. "%*"
end

---@param buf integer
---@return string[] parts, boolean truncated
local function path_parts(buf)
  local full = vim.api.nvim_buf_get_name(buf)
  if full == "" then
    return {}, false
  end
  full = vim.fs.normalize(full)

  local path = full
  if not state.absolute then
    local ok, root = pcall(function()
      return LazyVim.root.get({ normalize = true })
    end)
    if ok and root and root ~= "" and full:find(root, 1, true) == 1 then
      path = full:sub(#root + 2)
    else
      path = vim.fn.fnamemodify(full, ":~")
    end
  end

  return vim.split(path, "/", { trimempty = true }), false
end

---@param buf integer
---@param width integer
function M.build(buf, width)
  local parts = path_parts(buf)
  if #parts == 0 then
    return ""
  end

  -- 各セグメントが層かどうかを判定
  local layer_of = {}
  for i, p in ipairs(parts) do
    if i < #parts then
      layer_of[i] = LAYERS[p:lower()]
    end
  end

  -- 横幅に収まらないときは、層でもファイル名でもないセグメントを1文字に縮める。
  -- 区切り " › " は1つ3桁なので、それを含めて実際の表示幅で判定する。
  local SEP_W = 3
  local plain_w = (#parts - 1) * SEP_W + 3 -- 先頭の空白 + modified マーク分
  for _, p in ipairs(parts) do
    plain_w = plain_w + vim.fn.strdisplaywidth(p)
  end
  local abbrev = plain_w > width
  local rendered = {}
  for i, p in ipairs(parts) do
    if i == #parts then
      rendered[i] = hl("PathbarFile", p)
    elseif layer_of[i] then
      rendered[i] = hl(HL[layer_of[i]], p)
    elseif abbrev then
      rendered[i] = hl("PathbarDir", p:sub(1, 1))
    else
      rendered[i] = hl("PathbarDir", p)
    end
  end

  local sep = hl("PathbarSep", " › ")
  local out = " " .. table.concat(rendered, sep)
  if vim.bo[buf].modified then
    out = out .. hl("PathbarSep", " ●")
  end
  return out
end

-- winbar の %{% %} から呼ばれる。描画対象のウィンドウは statusline_winid で分かる。
function M.render()
  local win = vim.g.statusline_winid
  if not win or not vim.api.nvim_win_is_valid(win) then
    win = vim.api.nvim_get_current_win()
  end
  local ok, res = pcall(function()
    return M.build(vim.api.nvim_win_get_buf(win), vim.api.nvim_win_get_width(win))
  end)
  return ok and res or ""
end

local EXCLUDED_FT = {
  ["neo-tree"] = true,
  snacks_dashboard = true,
  snacks_picker_list = true,
  snacks_picker_input = true,
  snacks_terminal = true,
  help = true,
  qf = true,
  lazy = true,
  mason = true,
  trouble = true,
  toggleterm = true,
  TelescopePrompt = true,
  [""] = true,
}

local WINBAR = "%{%v:lua.require'core.pathbar'.render()%}"

local function should_show(win)
  if not state.enabled then
    return false
  end
  -- フローティングウィンドウには出さない
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype ~= "" then
    return false
  end
  if EXCLUDED_FT[vim.bo[buf].filetype] then
    return false
  end
  return vim.api.nvim_buf_get_name(buf) ~= ""
end

local function refresh()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      vim.wo[win].winbar = should_show(win) and WINBAR or nil
    end
  end
end

M.refresh = refresh

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "WinNew", "FileType", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("pathbar", { clear = true }),
  callback = function()
    vim.schedule(refresh)
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("pathbar_hl", { clear = true }),
  callback = set_hl,
})

-- LazyVim のキーマップは VeryLazy 以降に設定されるため、init.lua の時点で登録すると
-- 後から上書きされる（<leader>up は lazyvim/util/mini.lua:92 が Mini Pairs に使う）。
-- VeryLazy 後に登録して確実に自分のものを残す。
local function set_keymaps()
  vim.keymap.set("n", "<leader>uB", function()
    state.enabled = not state.enabled
    refresh()
    vim.notify("Path winbar: " .. (state.enabled and "on" or "off"), vim.log.levels.INFO, { title = "pathbar" })
  end, { desc = "Toggle Path Winbar" })

  vim.keymap.set("n", "<leader>uP", function()
    state.absolute = not state.absolute
    refresh()
    vim.notify("Path winbar: " .. (state.absolute and "absolute" or "root-relative"), vim.log.levels.INFO, { title = "pathbar" })
  end, { desc = "Toggle Path Winbar (absolute/relative)" })
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    set_keymaps()
    refresh()
  end,
})

vim.schedule(refresh)

return M
