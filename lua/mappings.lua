-- leader key is <Space>
vim.g.mapleader = " "

local map = vim.keymap.set

map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")
map("n", "<Space>", "<nop>")

-- easier to move around splits
map("n", "<C-h>", "<C-w><C-h>")
map("n", "<C-j>", "<C-w><C-j>")
map("n", "<C-k>", "<C-w><C-k>")
map("n", "<C-l>", "<C-w><C-l>")

-- TIP: Disable arrow keys in normal mode
map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- leave terminal mode easier
map('t', 'jk', '<C-\\><C-n>')
map('t', 'kj', '<C-\\><C-n>')

-- mappings for buffers
map('n', '<Tab>', '<cmd>bnext<CR>')
map('n', '<S-Tab>', '<cmd>bprev<CR>')


-- no highlights
map('n', '<leader>n', '<cmd>noh<CR>')

-- shows the floating window no matter what
map('n', '[d',
  function()
    vim.diagnostic.goto_prev()
    vim.diagnostic.open_float()
  end, { desc = "go to previous diagnostic and open floating window" }
)
map('n', ']d',
function()
  vim.diagnostic.goto_next()
  vim.diagnostic.open_float()
end, {desc = "go to next diagnostic and open floating window" }
)

-- moves around highlighted blocks
map('v', 'J', ":m '>+1<CR>gv=gv")
map('v', 'K', ":m '<-2<CR>gv=gv")

-- differentiate between system clipboard and nvim clipboard
map('n', '<leader>y', "\"+y")
map('v', '<leader>y', "\"+y")
map('n', '<leader>Y', "\"+Y")

-- delete to void register
map('n', '<leader>d', '\"_d')
map('v', '<leader>d', '\"_d')
