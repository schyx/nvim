-- setup plugins here
local plugins = {
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    -- Optional; default configuration will be used if setup isn't called.
    config = function()
      require("everforest").setup({
        background = "hard",
        disable_italic_comments = true,
        transparent_background_level = 1,
        ui_contrast = "high",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter", -- language parsing
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
  },
  -- {
  --   "folke/which-key.nvim", -- popup if I'm confused about vim keys
  --   event = "VeryLazy",
  --   init = function()
  --     vim.o.timeout = true
  --     vim.o.timeoutlen = 300
  --   end,
  -- },
  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "rebelot/heirline.nvim",
    -- You can optionally lazy-load heirline on UiEnter
    -- to make sure all required plugins and colorschemes are loaded before setup
    -- event = "UiEnter",
    config = function()
      require("configs.heirline")
    end,
  },
  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },
  {
    "hrsh7th/nvim-cmp", -- autocompletion
    event = "InsertEnter",
    dependencies = {
      {
        -- snippet plugin
        "L3MON4D3/LuaSnip",
        opts = { history = true, updateevents = "TextChanged,TextChangedI" },
        config = function(_, opts)
          require("luasnip").config.set_config(opts)
          -- snipmate format
          require("luasnip.loaders.from_snipmate").load()
          require("luasnip.loaders.from_snipmate").lazy_load({ paths = vim.g.snipmate_snippets_path or "" })
        end,
      },
      { -- autopairing of (){}[] etc
        "windwp/nvim-autopairs",
        opts = {
          fast_wrap = {},
          disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
          require("nvim-autopairs").setup(opts)
          -- setup cmp for autopairs
          -- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          -- require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
      },
      { -- cmp sources plugins
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { -- Customize or remove this keymap to your liking
        "<leader>c",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    -- Everything in opts will be passed to setup()
    opts = {
      -- Define your formatters
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rustfmt" },
        haskell = { "hls" },
      },
      -- Set up format-on-save
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
      -- Customize formatters
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
  -- { "mfussenegger/nvim-jdtls" },
  -- {
  --   "lervag/vimtex",
  --   lazy = false,
  --   init = function()
  --     vim.g.vimtex_view_general_viewer = "okular"
  --     vim.g.vimtex_view_general_options = [[--unique file:@pdf\#src:@line@tex]]
  --     vim.g.vimtex_quickfix_enabled = 1
  --     vim.g.vimtex_syntax_enabled = 1
  --     vim.g.vimtex_quickfix_mode = 0
  --   end,
  -- },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "goolord/alpha-nvim",
  },
}

local opts = {}

require("lazy").setup(plugins, opts)
require("configs")
