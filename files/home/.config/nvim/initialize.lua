-- nvim-tree settings
---- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

---- optionally enable 24-bit colour
vim.opt.termguicolors = true

---- setup nvim-tree using basic fonts instead of nerd fonts
require("nvim-tree").setup({
  renderer = {
    icons = {
      show = {
        git = true,
        file = false,
        folder = false,
        folder_arrow = true,
      },
      glyphs = {
        folder = {
          arrow_closed = "⏵",
          arrow_open = "⏷",
        },
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "⌥",
          renamed = "➜",
          untracked = "★",
          deleted = "⊖",
          ignored = "◌",
        },
      },
    },
  },
})

-- diffview settings
require("diffview").setup({
  use_icons = true,
  icons = {
    folder_closed = "▸",
    folder_open = "▾",
  },
  signs = {
    fold_closed = "▸",
    fold_open = "▾",
    done = "✓",
  },
})

