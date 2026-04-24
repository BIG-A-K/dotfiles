local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "nvim-treesitter/nvim-treesitter-context",
  {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      -- config
    }
  end,
  dependencies = { {'nvim-tree/nvim-web-devicons'}}
  },
  "shellRaining/hlchunk.nvim",
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
    }
  },
  --"github/copilot.vim",
  "preservim/nerdtree",
  "nvim-treesitter/nvim-treesitter",
  "neovim/nvim-lspconfig",
  "lambdalisue/fern.vim",
  "projekt0n/github-nvim-theme",
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end,
  },
  {
    "neoclide/coc.nvim",
    branch = "release",
  },
  {
    "ayu-theme/ayu-vim",
    config = function()
      vim.opt.termguicolors = true
      vim.cmd.colorscheme("ayu")
    end
  },
})

vim.opt.guifont = "HackGen Console NF:h12"

-- Treesitter 設定
--require'nvim-treesitter.configs'.setup {
--  highlight = {
--    enable = true,              -- false will disable the whole extension
--  },
--  -- Install parsers for different languages
--   ensure_installed = { "c", "cpp", "python", "lua", "javascript", "html", "css", "ruby", "rust" },
--}

-- Tab を使った補完の設定
vim.api.nvim_set_keymap('i', '<Tab>', 'coc#pum#visible() ? coc#pum#confirm() : "<Tab>"', { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('i', '<S-Tab>', 'coc#pum#visible() ? coc#pum#select_prev_item() : "<C-h>"', { noremap = true, silent = true, expr = true })

-- 行番号を表示する設定
vim.opt.number = true

-- インサートモードで 'jk' を押すとノーマルモードに戻るマッピング
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- 文字エンコーディングの設定
vim.opt.encoding = 'utf-8'
vim.scriptencoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.ambiwidth = 'single'
vim.opt.fileencodings = { 'ucs-boms', 'utf-8', 'euc-jp', 'cp932' }
vim.opt.fileformats = { 'unix', 'dos', 'mac' }



-- インデントの設定
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.shiftwidth = 2

-- カーソルの設定
vim.opt.whichwrap = 'b,s,h,l,<,>,[,],~'
vim.opt.cursorline = true

-- カーソル移動の設定
vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<down>', 'gj', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<up>', 'gk', { noremap = true, silent = true })

-- treeの表示
vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- バックスペースキーの有効化
vim.opt.backspace = { 'indent', 'eol', 'start' }

-- リスト表示の設定
vim.opt.list = true
vim.opt.listchars = { tab = '»-', trail = '-', eol = '↲', extends = '»', precedes = '«', nbsp = '%' }
vim.opt.nrformats:remove('octal')
vim.opt.hidden = true
vim.opt.history = 5000
vim.opt.wildmenu = true

vim.opt.virtualedit = 'block'
vim.opt.expandtab = true   -- Tabをスペースに変換
vim.opt.tabstop = 2        -- 画面上のタブ幅
vim.opt.softtabstop = 2    -- バックスペースで削除される幅
vim.opt.shiftwidth = 2     -- インデントの幅
vim.opt.autoindent = true  -- 自動インデント
vim.opt.smartindent = true -- スマートインデント

-- マウスを拒否
vim.opt.mouse = ""

-- シンタックスハイライトを有効にする
vim.cmd('syntax enable')

-- シンタックスハイライトの設定をカスタマイズする例
-- コメントを青色にする
vim.cmd('highlight Comment ctermfg=Blue guifg=Blue')

-- 関数名を太字にする
vim.cmd('highlight Function cterm=bold gui=bold')

--vim.cmd('colorscheme github_dark_colorblind')

