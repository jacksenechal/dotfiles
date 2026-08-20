-- Personal appearance overrides, tracked in ~/workspace/dotfiles. This is
-- Omarchy's own override file, loaded after the package defaults.

hl.config({
  general = {
    border_size = 0,  -- Omarchy 4 default: 2
  },

  decoration = {
    rounding = 8,     -- Omarchy 4 default: 0
  },

  misc = {
    -- Don't let apps steal focus by activation request.
    focus_on_activate = false,
  },
})
