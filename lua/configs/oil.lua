local function is_git_ignored_files_in(dir, name)
  if name == ".." then
    return false
  end

  local found = vim.fs.find(".git", {
    upward = true,
    path = dir,
  })

  if #found == 0 then
    return false
  end

  local handle = io.popen(string.format("git check-ignore %s", name))
  if handle == nil then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

local oil = require("oil")

oil.setup({
  view_options = {
    show_hidden = false,
    is_hidden_file = function(name, _)
      return is_git_ignored_files_in(oil.get_current_dir(), name)
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
vim.keymap.set("n", "<leader>x", function()
  local visible_bufs = vim.tbl_filter(function(bufnr)
    return 1 == vim.fn.buflisted(bufnr)
  end, vim.api.nvim_list_bufs())

  if #visible_bufs >= 2 then
    local key = vim.api.nvim_replace_termcodes("<cmd>bd<CR>", true, false, true)
    vim.api.nvim_feedkeys(key, "n", false)
  elseif #visible_bufs == 1 then
    local bufnr = vim.api.nvim_get_current_buf()
    local key = vim.api.nvim_replace_termcodes("<cmd>Oil<CR><cmd>" .. bufnr .. "bd<CR>", true, false, true)
    vim.api.nvim_feedkeys(key, "n", false)
  else
    print("No buffers open!")
  end
end, { desc = "close current buffer" })
