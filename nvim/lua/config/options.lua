local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 文字コード
-- ('encoding' は Neovim では常に utf-8 に固定されているため設定しない)
opt.fileencoding = "utf-8"
opt.fileencodings = { "ucs-bom", "utf-8", "euc-jp", "cp932" }
opt.fileformats = { "unix", "dos", "mac" }
opt.ambiwidth = "single"

-- 表示
opt.number = true
opt.cursorline = true
opt.signcolumn = "yes" -- 診断アイコンの出入りで画面がガタつくのを防ぐ
opt.scrolloff = 5
opt.termguicolors = true
opt.winborder = "rounded" -- hover / signature help などの浮動ウィンドウに枠
opt.guifont = "HackGen Console NF:h12"
opt.list = true
opt.listchars = { tab = "»-", trail = "-", eol = "↲", extends = "»", precedes = "«", nbsp = "%" }

-- インデント
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.autoindent = true
opt.smartindent = true

-- 検索
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split" -- :%s/... の結果をプレビュー

-- 編集
opt.clipboard = "unnamedplus" -- ヤンクを OS のクリップボードと共有
opt.undofile = true           -- undo をファイルを閉じても保持
opt.backspace = { "indent", "eol", "start" }
opt.whichwrap = "b,s,h,l,<,>,[,],~"
opt.virtualedit = "block"
opt.splitright = true
opt.splitbelow = true
opt.hidden = true
opt.history = 5000
opt.updatetime = 250
opt.timeoutlen = 400
opt.nrformats:remove("octal")

-- 補完（blink.cmp / 組み込み補完の両方に効く）
opt.completeopt = { "menu", "menuone", "noselect", "popup" }

-- マウスを拒否
opt.mouse = ""
