-- Input settings carried from the Omarchy 3.8.5 input.conf (archived 2026-08-18).
-- Only keys that differ from Omarchy 4's defaults are set here.

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
-- scroll_factor. Inert until the mouse is plugged in.
hl.device({
  name = "razer-razer-deathadder-essential-white-edition-1",
  sensitivity = -0.5,
  scroll_factor = 1.0,
  natural_scroll = true,
})

-- Three-finger touchpad gestures. Omarchy 4 ships none by default.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen", mode = "maximize" })
hl.gesture({ fingers = 3, direction = "swipe", mods = "SUPER", action = "resize" })
