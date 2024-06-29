local function get_git_ignored_files_in(dir)
  local found = vim.fs.find(".git", {
    upward = true,
    path = dir,
  })

  if #found == 0 then
    return {}
  end

  local cmd = string.format(
  'git -C %s ls-files --ignored --exclude-standard --others --directory | grep -v "/.*\\/"',
  dir
  )

  local handle = io.popen(cmd)
  if handle == nil then
    return
  end

  local ignored_files = {}
  for line in handle:lines "*l" do
    line = line:gsub("/$", "")
    table.insert(ignored_files, line)
  end
  handle:close()

  return ignored_files
end

local oil = require("oil")

oil.setup({
  view_options = {
    show_hidden = false,
    is_hidden_file = function(name, _)
      local ignored_files = get_git_ignored_files_in(oil.get_current_dir())
      return vim.tbl_contains(ignored_files, name)
    end,
  },

  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-s>"] = "actions.select_vsplit",
    ["<C-t>"] = "actions.select_tab",
    ["<C-n>"] = "actions.close",
    ["<C-r>"] = "actions.refresh",
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = "actions.tcd",
    ["gs"] = "actions.change_sort",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
    ["g\\"] = "actions.toggle_trash",
  },
  use_default_keynmaps = false,
})

vim.keymap.set("n", "<C-n>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>v", "<CMD>vsplit<CR><CMD>Oil<CR>", { desc = "Open a vertical split in oil"})
vim.keymap.set('n', '<leader>x',
  function()
    local visible_bufs = vim.tbl_filter(function (bufnr)
      return 1 == vim.fn.buflisted(bufnr)
    end, vim.api.nvim_list_bufs())

    if #visible_bufs >= 2 then
      local key = vim.api.nvim_replace_termcodes('<cmd>bd<CR>', true, false, true)
      vim.api.nvim_feedkeys(key, 'n', false)
    elseif #visible_bufs == 1 then
      local bufnr = vim.api.nvim_get_current_buf()
      local key = vim.api.nvim_replace_termcodes('<cmd>Oil<CR><cmd>' .. bufnr .. 'bd<CR>', true, false, true)
      vim.api.nvim_feedkeys(key, 'n', false)
    else
      print("No buffers open!")
    end
  end,
  { desc = "close current buffer" }
)
