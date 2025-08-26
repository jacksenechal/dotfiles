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
-- vim.cmd[[colorscheme tokyonight]]
-- require("tokyonight").setup({
--   -- your configuration comes here
--   -- or leave it empty to use the default settings
--   style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
--   light_style = "day", -- The theme is used when the background is set to light
--   transparent = false, -- Enable this to disable setting the background color
--   day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
--   dim_inactive = true, -- dims inactive windows
-- })

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

------------------ colorscheme background toggle ------------------
-- Define a variable to keep track of the current background mode
vim.g.my_bg_mode = 'default'

-- Define a variable to keep track of the current color scheme
vim.g.my_colorscheme = vim.g.colors_name

-- Define a function to apply the background mode
function ApplyBackgroundMode()
  if vim.g.my_bg_mode == 'transparent' then
    vim.cmd[[highlight Normal guibg=NONE ctermbg=NONE]]
    vim.cmd[[highlight NormalNC guibg=NONE ctermbg=NONE]]
    vim.cmd[[highlight nonText guibg=NONE ctermbg=NONE]]
  else
    vim.cmd('colorscheme ' .. vim.g.my_colorscheme)
  end
end

-- Define a function to toggle the background mode
function ToggleBackground()
  if vim.g.my_bg_mode == 'default' then
    vim.g.my_bg_mode = 'transparent'
  else
    vim.g.my_bg_mode = 'default'
  end
  ApplyBackgroundMode()
  -- Write the current background mode to a file
  vim.fn.writefile({vim.g.my_bg_mode}, vim.fn.stdpath('config') .. '/bg_mode')
end

-- Define a command to call the function
vim.cmd[[command! ToggleBG lua ToggleBackground()]]

-- Define an autocmd to remember the current color scheme
vim.cmd[[autocmd ColorScheme * let g:my_colorscheme = g:colors_name]]

-- Define a function to load the background mode
function LoadBackgroundMode()
  local bg_mode_file = vim.fn.stdpath('config') .. '/bg_mode'
  if vim.fn.filereadable(bg_mode_file) == 1 then
    vim.g.my_bg_mode = vim.fn.readfile(bg_mode_file)[1]
    ApplyBackgroundMode()
  end
end

-- Call the function when Vim starts
LoadBackgroundMode()
