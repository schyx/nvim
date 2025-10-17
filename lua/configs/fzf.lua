require("fzf-lua").setup({})

vim.keymap.set("n", "<leader>ff", "<CMD>FzfLua files<CR>")
vim.keymap.set("n", "<leader>fg", "<CMD>FzfLua live_grep<CR>")
vim.keymap.set("n", "<leader>fb", "<CMD>FzfLua buffers<CR>")
vim.keymap.set("n", "<leader>fr", "<CMD>FzfLua oldfiles<CR>")
vim.keymap.set("n", "<leader><leader>", "<CMD>FzfLua builtin<CR>")
