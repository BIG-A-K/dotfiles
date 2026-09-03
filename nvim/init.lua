-- エントリポイント。実体は lua/config/ 以下と lua/plugins/ 以下にある。
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy") -- プラグインを読み込む（同期）
require("config.lsp")  -- nvim-lspconfig の lsp/*.lua に依存するので lazy の後
