require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "lua_ls",
  },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local on_attach = function() end

local lua_settings = {
  Lua = {
    runtime = { version = "LuaJIT" },
    workspace = {
      library = {
        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
        [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
      },
      maxPreload = 100000,
      preloadFileSize = 10000,
    },
  },
}

vim.lsp.config("*", {capabilities = capabilities, on_init = on_attach})
vim.lsp.config("lua_ls", {settings = lua_settings})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

