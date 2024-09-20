--- @param sc string
--- @param txt string
--- @param keybind string? optional
--- @param keybind_opts table? optional
local function button(sc, txt, keybind, keybind_opts)
  local opts = {
    position = "center",
    shortcut = sc,
    cursor = 3,
    width = 50,
    align_shortcut = "right",
    hl_shortcut = "Type",
  }
  if keybind then
    keybind_opts = vim.F.if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
    opts.keymap = { "n", sc, keybind, keybind_opts }
  end

  local function on_press()
    local key = vim.api.nvim_replace_termcodes(keybind or sc .. "<Ignore>", true, false, true)
    vim.api.nvim_feedkeys(key, "t", false)
  end

  return {
    type = "button",
    val = txt,
    on_press = on_press,
    opts = opts,
  }
end

local menu = {
  button("o", "  > Open Oil", "<CMD>Oil<CR>"),
  button("f", "  > Find file", "<CMD>FzfLua files<CR>"),
  button("r", "  > Recent", "<CMD>FzfLua oldfiles<CR>"),
  button("g", "󰈬  > Find word", "<CMD>FzfLua live_grep<CR>"),
  button("s", "  > Settings", "<CMD>cd ~/.config/nvim<CR><CMD>Oil<CR>"),
  button("q", "  > Quit NVIM", ":qa<CR>"),
}

vim.api.nvim_set_hl(0, "HeaderColor", { fg = "#bea9df" })

local function get_quote()
  local quotes = require("configs.quotes")
  math.randomseed(os.time())
  local ind = math.random(1, #quotes)
  return quotes[ind]
end

local layout = {
  { type = "padding", val = 2 },
  {
    type = "text",
    val = {
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣶⣾⣷⣶⣦⣄⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⣠⣾⡇⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀",
      "⢀⣀⣀⣀⣠⣴⣾⣿⣿⠃⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆",
      "⠈⠻⢿⣿⣿⣿⡿⣟⠃⠀⣀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡧",
      "⠀⠀⠀⠀⠈⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣼⣿⣿⣿⣿⣿⣿⠇",
      "⠀⠀⠀⠀⠀⠀⠀⠈⠙⢻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠛⡙⠛⢛⡻⠋⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠒⠄⠬⢉⣡⣠⣿⣿⣿⣇⡌⠲⠠⠋⠈⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    },
    opts = {
      hl = "HeaderColor",
      position = "center",
    },
  },
  { type = "padding", val = 2 },
  {
    type = "group",
    val = menu,
    opts = { spacing = 1 },
  },
  { type = "padding", val = 2 },
  { type = "text", val = get_quote(), opts = { position = "center", hl = "Error" } },
}

-- Send config to alpha
require("alpha").setup({ layout = layout })

-- Disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
