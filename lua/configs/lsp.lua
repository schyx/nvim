require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls" },
})

-- keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "<leader>c", vim.lsp.buf.format)

-- lsp-specific setups
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }
      }
    }
  }
})

