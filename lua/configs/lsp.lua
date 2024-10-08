require("mason").setup()

local servers = {
  "lua_ls",
  "pylsp",
  "texlab",
  "ruff",
  "rust_analyzer",
  "clangd",
}

require("mason-lspconfig").setup({
  ensure_installed = servers,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function() end

local lspconfig = require("lspconfig")

for _, lsp in ipairs(servers) do
  if lsp ~= "lua_ls" then
    lspconfig[lsp].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end
end

lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
})

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
