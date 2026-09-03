return {
  {
    -- master ブランチを使う。main ブランチは tree-sitter CLI の追加インストールを
    -- 要求するため、外部依存を増やさない master に留めている。
    -- (master は上流でロック済み＝新機能は入らないが、動作はする)
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "bash", "c", "cpp", "css", "diff", "gitcommit", "gitignore",
        "html", "javascript", "json", "jsonc", "lua", "luadoc", "make",
        "markdown", "markdown_inline", "python", "query", "regex", "rust",
        "toml", "tsx", "typescript", "vim", "vimdoc", "yaml",
      },
      auto_install = false, -- 未知のファイルタイプで勝手に取りに行かせない
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          node_decremental = "<BS>",
          scope_incremental = false,
        },
      },
    },
  },
  {
    -- 画面外にはみ出した関数・クラスのヘッダを最上部に固定表示する
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { max_lines = 3 },
  },
}
