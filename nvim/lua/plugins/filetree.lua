return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "ファイルツリーの開閉" },
      { "<leader>fe", "<cmd>NvimTreeFindFile<CR>", desc = "ツリー上で現在のファイルを表示" },
    },
    opts = {
      view = { width = 32 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
      git = { enable = true },
      diagnostics = { enable = true },
    },
  },
}
