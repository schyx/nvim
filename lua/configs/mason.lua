require("mason").setup()
require("mason-lspconfig").setup()

vim.keymap.set("n", "<leader>c", vim.lsp.buf.format)

