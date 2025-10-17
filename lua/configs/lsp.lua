require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "hls",
    "lua_ls",
  },
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("hls")
