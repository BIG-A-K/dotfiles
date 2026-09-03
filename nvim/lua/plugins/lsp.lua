return {
  -- サーバ定義の供給元。設定自体は lua/config/lsp.lua で行う
  { "neovim/nvim-lspconfig", lazy = false },

  -- 言語サーバ / フォーマッタのインストーラ
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = { ui = { border = "rounded" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "lua_ls", "pyright", "clangd", "rust_analyzer", "ts_ls", "bashls", "jsonls",
      },
      -- 有効化は lua/config/lsp.lua の vim.lsp.enable() で明示的に行う
      automatic_enable = false,
    },
  },

  -- 補完
  {
    "saghen/blink.cmp",
    version = "1.*", -- ビルド済みバイナリを使う（cargo ビルド不要）
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default" }, -- <C-y> 確定 / <C-n> <C-p> 選択 / <C-space> 補完メニュー
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = true },
      },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      signature = { enabled = true },
    },
  },
}
