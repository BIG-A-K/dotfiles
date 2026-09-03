return {
  {
    "ayu-theme/ayu-vim",
    lazy = false,
    priority = 1000, -- 他のプラグインより先に読み込む
    config = function()
      vim.g.ayucolor = "dark" -- "light" | "mirage" | "dark"
      vim.cmd.colorscheme("ayu")
    end,
  },
}
