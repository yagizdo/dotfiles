-- Custom plugins for Flutter/mobile development
return {
  -- Catppuccin colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
    },
  },

  -- Set colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- Flutter tools
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = true,
  },

  -- Dart syntax highlighting
  {
    "dart-lang/dart-vim-plugin",
    ft = "dart",
  },
}
