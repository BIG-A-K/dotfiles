return {
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- メッセージ / コマンドライン / ポップアップの見た目
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        section_separators = "",
        component_separators = "|",
      },
      sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
          "encoding",
          "fileformat",
          "filetype",
        },
      },
    },
  },

  -- スタート画面
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      theme = "hyper",
      config = {
        week_header = { enable = true },
        shortcut = {
          { desc = " Update", group = "@property", action = "Lazy update", key = "u" },
          { desc = " Files", group = "Label", action = "Telescope find_files", key = "f" },
          { desc = " Recent", group = "Number", action = "Telescope oldfiles", key = "r" },
          { desc = " Config", group = "Constant", action = "edit ~/.config/nvim/init.lua", key = "c" },
        },
      },
    },
  },

  -- インデントガイド / チャンクの可視化
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      chunk = { enable = true },
      indent = { enable = true },
      line_num = { enable = false },
      blank = { enable = false },
    },
  },
}
