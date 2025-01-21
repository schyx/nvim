local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

-- setup colors
local function setup_colors()
  return {
    bright_bg = utils.get_highlight("Folded").bg,
    bright_fg = utils.get_highlight("Folded").fg,
    red = utils.get_highlight("DiagnosticError").fg,
    dark_red = utils.get_highlight("DiffDelete").bg,
    green = utils.get_highlight("String").fg,
    blue = utils.get_highlight("Function").fg,
    gray = utils.get_highlight("NonText").fg,
    orange = utils.get_highlight("Constant").fg,
    purple = "#b19cd9", -- hard code it to actually purple
    cyan = utils.get_highlight("Special").fg,
    diag_warn = utils.get_highlight("DiagnosticWarn").fg,
    diag_error = utils.get_highlight("DiagnosticError").fg,
    diag_hint = utils.get_highlight("DiagnosticHint").fg,
    diag_info = utils.get_highlight("DiagnosticInfo").fg,
    git_del = utils.get_highlight("diffDeleted").fg,
    git_add = utils.get_highlight("diffAdded").fg,
    git_change = utils.get_highlight("diffChanged").fg,
    nvim_bg = "#1E2326", -- background of neovim
  }
end

local colors = setup_colors()

vim.api.nvim_create_augroup("Heirline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    utils.on_colorscheme(setup_colors)
  end,
  group = "Heirline",
})

-- setup mode
local ViMode = {
  -- get vim current mode, this information will be required by the provider
  -- and the highlight functions, so we compute it only once per component
  -- evaluation and store it as a component attribute
  init = function(self)
    self.mode = vim.fn.mode(1) -- :h mode()
  end,
  -- Now we define some dictionaries to map the output of mode() to the
  -- corresponding string and color. We can put these into `static` to compute
  -- them at initialisation time.
  static = {
    mode_names = { -- change the strings if you like it vvvvverbose!
      n = "N",
      no = "N",
      nov = "N",
      noV = "N",
      ["no\22"] = "N",
      niI = "N",
      niR = "N",
      niV = "N",
      nt = "N",
      v = "V",
      vs = "V",
      V = "V",
      Vs = "V",
      ["\22"] = "V",
      ["\22s"] = "V",
      s = "S",
      S = "S",
      ["\19"] = "S",
      i = "I",
      ic = "I",
      ix = "I",
      R = "R",
      Rc = "R",
      Rx = "R",
      Rv = "R",
      Rvc = "R",
      Rvx = "R",
      c = "C",
      cv = "Ex",
      r = "...",
      rm = "M",
      ["r?"] = "?",
      ["!"] = "!",
      t = "T",
    },
    mode_colors = {
      n = "green",
      i = "purple",
      v = "cyan",
      V = "cyan",
      ["\22"] = "cyan",
      c = "orange",
      s = "red",
      S = "red",
      ["\19"] = "red",
      R = "orange",
      r = "orange",
      ["!"] = "red",
      t = "red",
    },
  },
  -- We can now access the value of mode() that, by now, would have been
  -- computed by `init()` and use it to index our strings dictionary.
  -- note how `static` fields become just regular attributes once the
  -- component is instantiated.
  -- To be extra meticulous, we can also add some vim statusline syntax to
  -- control the padding and make sure our string is always at least 6
  -- characters long.
  provider = function(self)
    return " " .. self.mode_names[self.mode] .. "" -- 
  end,
  hl = function(self)
    local mode = self.mode:sub(1, 1) -- get only the first mode character
    return { fg = colors.bright_bg, bg = self.mode_colors[mode], bold = true }
  end,
  -- Re-evaluate the component only on ModeChanged event!
  -- Also allows the statusline to be re-evaluated when entering operator-pending mode
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
      vim.cmd("redrawstatus")
    end),
  },
}

local FileNameBlock = {
  -- let's first set up some attributes needed by this component and its children
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
}
-- We can now define some children separately and add them later

local FileIcon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
  end,
  provider = function(self)
    return self.icon and (self.icon .. " ")
  end,
  hl = function(self)
    return { fg = self.icon_color, bg = colors.bright_bg }
  end,
}

local FileName = {
  provider = function(self)
    -- first, trim the pattern relative to the current directory. For other
    -- options, see :h filename-modifers
    local filename = vim.fn.fnamemodify(self.filename, ":.") .. " "
    if filename == "" then
      return "[No Name]"
    end
    -- now, if the filename would occupy more than 1/4th of the available
    -- space, we trim the file path to its initials
    -- See Flexible Components section below for dynamic truncation
    if not conditions.width_percent_below(#filename, 0.25) then
      filename = vim.fn.pathshorten(filename)
    end
    return filename
  end,
  hl = { bg = colors.bright_bg },
}

-- let's add the children to our FileNameBlock component
FileNameBlock = utils.insert(
  FileNameBlock,
  FileIcon,
  FileName, -- a new table where FileName is a child of FileNameModifier
  { provider = "%<" } -- this means that the statusline is cut here when there's not enough space
)

local Diagnostics = {

  condition = conditions.has_diagnostics,

  static = {
    error_icon = "",
    warn_icon = "",
    info_icon = "",
    hint_icon = "󱥸",
  },

  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,

  update = { "DiagnosticChanged", "BufEnter" },

  {
    provider = function(self)
      -- 0 is just another output, we can decide to print it or not!
      return self.errors > 0 and (self.error_icon .. self.errors .. " ")
    end,
    hl = { fg = "diag_error" },
  },
  {
    provider = function(self)
      return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
    end,
    hl = { fg = "diag_warn" },
  },
  {
    provider = function(self)
      return self.info > 0 and (self.info_icon .. self.info .. " ")
    end,
    hl = { fg = "diag_info" },
  },
  {
    provider = function(self)
      return self.hints > 0 and (self.hint_icon .. self.hints)
    end,
    hl = { fg = "diag_hint" },
  },
}

local FileType = {
  provider = function()
    return string.upper(vim.bo.filetype) .. " "
  end,
  hl = { bold = true },
}

local FileFormat = {
  provider = function()
    local fmt = vim.bo.fileformat
    return fmt ~= "unix" and fmt:upper()
  end,
}

local Time = {
  provider = function()
    return " " .. os.date("%H:%M") .. " "
  end,
  update = {
    "CursorHold",
    updatetime = "1000",
  },
  hl = { bg = colors.bright_bg },
}

-- We're getting minimalist here!
local Ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  provider = "%7(%4l:%2c",
  hl = { fg = colors.bright_bg, bg = "purple" },
}

local Align = { provider = "%=", hl = { bg = colors.nvim_bg } }
local Space = { provider = " ", hl = { bg = colors.bright_bg } }
local RightArrow = {
  provider = "",
  hl = {
    fg = colors.bright_bg,
  },
}
local LeftArrow = {
  provider = "",
  hl = {
    fg = colors.bright_bg,
  },
}

local StatusLine = {
  ViMode,
  Space,
  FileNameBlock,
  RightArrow,
  Diagnostics,
  Align,
  FileType,
  FileFormat,
  LeftArrow,
  Time,
  Ruler,
}

require("heirline").setup({
  statusline = StatusLine,
  opts = {
    colors = setup_colors(),
  },
})
