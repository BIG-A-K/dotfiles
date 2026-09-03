return {
  -- ファジーファインダ（ripgrep を使う）
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        -- ネイティブの fzf ソータ。make が必要
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          pcall(require("telescope").load_extension, "fzf")
        end,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "ファイル検索" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "全文検索(grep)" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "バッファ一覧" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "ヘルプ検索" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "最近使ったファイル" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "診断一覧" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "シンボル一覧" },
    },
    -- opts を関数にしないと、telescope が runtimepath に載る前に
    -- require("telescope.actions") が評価されて起動時に落ちる
    opts = function()
      return {
        defaults = {
          prompt_prefix = "  ",
          selection_caret = " ",
          path_display = { "truncate" },
          mappings = { i = { ["<Esc>"] = require("telescope.actions").close } },
        },
      }
    end,
  },

  -- git の差分表示
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "]c", function() gs.nav_hunk("next") end, "次の変更箇所")
        map("n", "[c", function() gs.nav_hunk("prev") end, "前の変更箇所")
        map("n", "<leader>hs", gs.stage_hunk, "ハンクを stage")
        map("n", "<leader>hr", gs.reset_hunk, "ハンクを reset")
        map("n", "<leader>hp", gs.preview_hunk, "ハンクをプレビュー")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "行の blame")
        map("n", "<leader>hd", gs.diffthis, "この行の diff")
      end,
    },
  },

  -- 囲み文字の操作（cs"' / ysiw" / ds" など）
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- 括弧・クォートの自動補完
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- キーマップのヒント表示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>f", group = "検索(find)" },
        { "<leader>h", group = "git ハンク" },
        { "<leader>b", group = "バッファ" },
        { "<leader>u", group = "切り替え(toggle)" },
      },
    },
  },
}
