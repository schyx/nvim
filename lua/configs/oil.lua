local git_ignored = setmetatable({}, {
  __index = function(self, key)
    local proc = vim.system({ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" }, {
      cwd = key,
      text = true,
    })
    local result = proc:wait()
    local ret = {}
    if result.code == 0 then
      for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
        -- Remove trailing slash
        line = line:gsub("/$", "")
        table.insert(ret, line)
      end
    end

    rawset(self, key, ret)
    return ret
  end,
})

local oil = require("oil")

oil.setup({
  view_options = {
    show_hidden = false,
    is_hidden_file = function(name, _)
      local dir = require("oil").get_current_dir()
      return vim.list_contains(git_ignored[dir], name)
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
vim.keymap.set("n", "<leader>v", "<CMD>vsplit<CR><CMD>Oil<CR>", { desc = "Open a vertical split in oil" })
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
