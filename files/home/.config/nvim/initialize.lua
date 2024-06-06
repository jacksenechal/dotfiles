-- nvim-tree settings
---- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

---- optionally enable 24-bit colour
vim.opt.termguicolors = true

---- nightfly theme settings
-- vim.cmd [[colorscheme nightfly]]
-- vim.g.nightflyTransparent = true
-- vim.g.nightflyWinSeparator = 2
-- vim.opt.fillchars = { horiz = '━', horizup = '┻', horizdown = '┳', vert = '┃', vertleft = '┫', vertright = '┣', verthoriz = '╋', }

---- tokyonight theme settings
vim.cmd[[colorscheme tokyonight]]
require("tokyonight").setup({
  -- your configuration comes here
  -- or leave it empty to use the default settings
  style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
  light_style = "day", -- The theme is used when the background is set to light
  transparent = false, -- Enable this to disable setting the background color
  day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
  dim_inactive = true, -- dims inactive windows
})

---- setup nvim-tree using basic fonts instead of nerd fonts
require("nvim-tree").setup({
  update_focused_file = {
    enable = true,
  },
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

