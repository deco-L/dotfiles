if false then
  return {}
end

return {
  {
    "mistweaverco/kulala.nvim",
    -- v6.0.0 以降は kulala-core が private 化され、ライセンストークンが必須。
    -- トークン不要で動く最後のリリースが v5.3.4（2026-02-08）。
    -- 上げるときは lazy-lock.json も :Lazy update kulala.nvim で更新すること。
    tag = "v5.3.4",
    -- fmt サブモジュール(kulala-fmt)の init が途中で死に、.git/modules/fmt が
    -- config だけの空リポジトリとして残る。git が再帰のたびに
    -- `fatal: not a git repository` で落ちて checkout が中断し、
    -- worktree が埋まりきらないまま「ローカル変更あり」と判定されて
    -- lazy がタグへの切り替えを拒否する。fmt は実行時に使わないので再帰を止める。
    submodules = false,
    -- Load before session save/restore so VimLeavePre and SessionLoadPost hooks are registered.
    event = { "SessionLoadPost", "VimLeavePre" },
    keys = {
      { "<leader>Rs", desc = "Send request" },
      { "<leader>Ra", desc = "Send all requests" },
      { "<leader>Rb", desc = "Open scratchpad" },
    },
    ft = { "http", "rest" },
    opts = {
      -- dev, test, prod, can be anything
      -- see: https://learn.microsoft.com/en-us/aspnet/core/test/http-files?view=aspnetcore-8.0#environment-files
      default_env = "default",
      -- `"b"` = per-buffer env (default), `"g"` = global
      environment_scope = "b",
      -- enable reading vscode rest client environment variables
      vscode_rest_client_environmentvars = false,

      ui = {
        -- display mode: possible values: "split", "float"
        display_mode = "split",
        -- split direction: v5 は "vertical" | "horizontal"
        -- ("right" を渡すと vertical と一致せず below になる)
        split_direction = "vertical",
        -- window options to override win_config: width/height/split/vertical.., buffer/window options
        win_opts = { bo = {}, wo = {} }, ---@type kulala.ui.win_config
        -- default view: "body" or "headers" or "headers_body" or "verbose" or fun(response: Response)
        default_view = "body", ---@type "body"|"headers"|"headers_body"|"verbose"|fun(response: Response)
        -- enable winbar
        winbar = true,
        -- Specify the panes to be displayed by default
        -- Available panes are { "body", "headers", "headers_body", "script_output", "stats", "verbose", "report", "help" },
        default_winbar_panes = { "body", "headers", "verbose", "script_output", "report" },
        -- Winbar labels
        winbar_labels = {
          body = "Body",
          headers = "Headers",
          headers_body = "All",
          verbose = "Verbose",
          script_output = "Script Output",
          stats = "Stats",
          report = "Report",
          help = "Help",
        },
        -- show/hide winbar keymaps in labels
        winbar_labels_keymaps = true,
        -- enable/disable variable info text
        -- this will show the variable name and value as float
        -- possible values: false, "float"
        show_variable_info_text = false,
        -- icons position: "signcolumn"|"on_request"|"above_request"|"below_request" or nil to disable
        show_icons = "on_request",
        -- default icons
        icons = {
          inlay = {
            loading = "⏳",
            done = "✔",
            error = "✘",
          },
          lualine = "🐼",
          textHighlight = "WarningMsg", -- highlight group for request elapsed time
          loadingHighlight = "Normal",
          doneHighlight = "String",
          errorHighlight = "ErrorMsg",
        },

        -- enable/disable request summary in the output window
        show_request_summary = true,

        -- do not show responses over maximum size, in bytes
        max_response_size = 32768,

        -- used by `Copy as Curl` command to determine whether to inline request body
        max_request_size = 2048,

        report = {
          -- possible values: true | false | "on_error"
          show_script_output = true,
          -- possible values: true | false | "on_error" | "failed_only"
          show_asserts_output = true,
          -- possible values: true | false | "on_error"
          show_summary = true,

          headersHighlight = "Special",
          successHighlight = "String",
          errorHighlight = "Error",
        },

        -- scratchpad default contents
        scratchpad_default_contents = {
          "@MY_TOKEN_NAME=my_token_value",
          "",
          "# @name scratchpad",
          "POST https://echo.kulala.app/post HTTP/1.1",
          "accept: application/json",
          "content-type: application/json",
          "",
          "{",
          '  "foo": "bar"',
          "}",
        },

        -- Settings for pickers used for Environment, Authentication and Requests Managers
        pickers = {
          snacks = {
            layout = function()
              local has_snacks, snacks_picker = pcall(require, "snacks.picker")
              return not has_snacks and {}
                or vim.tbl_deep_extend("force", snacks_picker.config.layout("telescope"), {
                  reverse = true,
                  layout = {
                    { { win = "list" }, { height = 1, win = "input" }, box = "vertical" },
                    { win = "preview", width = 0.6 },
                    box = "horizontal",
                    width = 0.8,
                  },
                })
            end,
          },
        },
      },

      lsp = {
        ---enable/disable built-in LSP server
        ---@type boolean
        enable = true,

        ---filetypes to attach Kulala LSP to
        ---v5 には enforce_external_script_naming_convention が無く、
        ---javascript/typescript/lua を入れると全バッファに LSP が付くため絞る。
        ---@type string[]
        filetypes = { "http", "rest" },

        --enable/disable/customize  LSP keymaps
        ---@type boolean|table
        keymaps = false, -- disabled by default, as Kulala relies on default Neovim LSP keymaps

        on_attach = nil, -- function called when Kulala LSP attaches to the buffer
      },

      -- enable/disable debug mode
      debug = 3,
      -- enable/disable bug reports on all errors
      generate_bug_report = false,

      -- set to true to enable default keymaps
      -- (see docs or lua/kulala/config/keymaps.lua)
      -- or override default keymaps as shown in the example below.
      ---@type boolean|table
      global_keymaps = true,
      --[[
        {
          ["Send request"] = { -- sets global mapping
            "<leader>Rs",
            function() require("kulala").run() end,
            mode = { "n", "v" }, -- optional mode, default is n
            desc = "Send request" -- optional description, otherwise inferred from the key
          },
          ["Send all requests"] = {
            "<leader>Ra",
            function() require("kulala").run_all() end,
            mode = { "n", "v" },
            ft = "http", -- sets mapping for *.http files only
          },
          ["Replay the last request"] = {
            "<leader>Rr",
            function() require("kulala").replay() end,
            ft = { "http", "rest" }, -- sets mapping for specified file types
          },
        ["Find request"] = false -- set to false to disable
        },
      ]]

      -- Prefix for global keymaps
      global_keymaps_prefix = "<leader>R",

      -- Kulala UI keymaps; override with custom keymaps as required
      -- (see docs or lua/kulala/config/keymaps.lua)
      ---@type boolean|table
      kulala_keymaps = {
        ["Previous tab"] = false,
        ["Next tab"] = false,
      },
      --[[
        {
          ["Show headers"] = { "H", function() require("kulala.ui").show_headers() end, },
        }
      ]]

      kulala_keymaps_prefix = "",



    },
  },
}
