-- Personal input overrides, tracked in ~/workspace/dotfiles.
-- This is Omarchy's own override file: hyprland.lua requires it after the
-- package defaults, so anything set here wins. Only keys that differ from
-- Omarchy 4's defaults are set, so the defaults keep improving underneath.

hl.config({
  input = {
    -- Compose on Right Alt, leaving Caps Lock as Caps Lock. Omarchy 4 defaults
    -- to compose:caps plus shift:both_capslock_cancel instead.
    kb_options = "compose:ralt",

    -- Slower to start repeating (Omarchy 4 default: 250).
    repeat_delay = 600,

    -- Natural (inverse) scrolling on mice as well as the touchpad.
    natural_scroll = true,

    touchpad = {
      natural_scroll = true,
      -- Repeated on purpose: matches both the old value and the Omarchy 4
      -- default, so it is a no-op if hl.config merges nested tables and a
      -- safeguard if it replaces them.
      clickfinger_behavior = true,
      scroll_factor = 0.2,
    },
  },
})

-- Razer DeathAdder: lower sensitivity, and don't inherit the touchpad's
-- scroll_factor. `sensitivity` runs -1.0 (slowest) to 1.0 (fastest), 0 = default.
--
-- The device exposes several HID endpoints and Hyprland disambiguates them with a
-- numeric suffix whose assignment is not stable across sessions. As of 2026-08-20
-- the pointer is the bare name while the "-1" suffix belongs to a *keyboard*
-- endpoint, so a rule aimed at "-1" was applied to a keyboard and silently ignored.
-- Verify with `hyprctl devices` and read the "mice:" block, not "Keyboards:".
-- Both names are covered below; a device rule aimed at a keyboard is a no-op.
local deathadder = {
  sensitivity = -0.75,
  scroll_factor = 1.0,
  natural_scroll = true,
}

for _, name in ipairs({
  "razer-razer-deathadder-essential-white-edition",
  "razer-razer-deathadder-essential-white-edition-1",
}) do
  local rule = { name = name }
  for key, value in pairs(deathadder) do
    rule[key] = value
  end
  hl.device(rule)
end

-- Three-finger touchpad gestures. Omarchy 4 ships none by default.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen", mode = "maximize" })
hl.gesture({ fingers = 3, direction = "swipe", mods = "SUPER", action = "resize" })
