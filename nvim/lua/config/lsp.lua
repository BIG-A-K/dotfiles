-- LSP 設定。サーバ本体は mason.nvim で入れ、
-- 個々のサーバ定義は nvim-lspconfig が同梱する lsp/*.lua を
-- Neovim 0.11+ の vim.lsp.enable() が runtimepath から拾う。

-- 補完クライアントの capabilities を全サーバ共通のデフォルトにする
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end
vim.lsp.config("*", { capabilities = capabilities })

-- サーバ個別の上書き
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

-- 有効化するサーバ（mason-lspconfig の ensure_installed と揃えておく）
vim.lsp.enable({
  "lua_ls",
  "pyright",
  "clangd",
  "rust_analyzer",
  "ts_ls",
  "bashls",
  "jsonls",
})

-- 診断の見た目
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
})

-- バッファローカルのキーマップ
-- Neovim 0.11+ は grn(rename) / gra(code action) / grr(references) /
-- gri(implementation) / gO(document symbol) / K(hover) を既定で用意している。
-- ここではそこに無いものだけ足す。
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("dotfiles_lsp_attach", { clear = true }),
  callback = function(ev)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("n", "gd", vim.lsp.buf.definition, "定義へジャンプ")
    map("n", "gD", vim.lsp.buf.declaration, "宣言へジャンプ")
    map("n", "gy", vim.lsp.buf.type_definition, "型定義へジャンプ")
    map("i", "<C-s>", vim.lsp.buf.signature_help, "シグネチャヘルプ")

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- カーソル下のシンボルを同一バッファ内でハイライト
    if client and client:supports_method("textDocument/documentHighlight") then
      local group = vim.api.nvim_create_augroup("dotfiles_lsp_highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = ev.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = ev.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
    -- インレイヒント（対応サーバのみ）
    if client and client:supports_method("textDocument/inlayHint") then
      map("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
      end, "インレイヒントの切り替え")
    end
  end,
})
