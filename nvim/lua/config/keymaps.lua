local map = vim.keymap.set

-- インサートモードで jk を押すとノーマルモードに戻る
map("i", "jk", "<Esc>")

-- 表示行単位でカーソルを動かす（折り返し行の中を移動できる）
map({ "n", "x" }, "j", "gj")
map({ "n", "x" }, "k", "gk")
map({ "n", "x" }, "<Down>", "gj")
map({ "n", "x" }, "<Up>", "gk")

-- Esc で検索ハイライトを消す
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- ウィンドウ移動
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- バッファ移動
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "次のバッファ" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "前のバッファ" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "バッファを閉じる" })

-- ビジュアルモードでインデントを繰り返す
map("x", "<", "<gv")
map("x", ">", ">gv")

-- 選択範囲を上下に移動
map("x", "J", ":move '>+1<CR>gv=gv")
map("x", "K", ":move '<-2<CR>gv=gv")

-- 診断
-- ]d / [d による診断ジャンプは Neovim 0.11+ の組み込みマッピングをそのまま使う
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "診断を浮動ウィンドウで表示" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "診断を location list へ" })
