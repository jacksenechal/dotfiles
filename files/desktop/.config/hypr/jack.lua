-- Personal Hyprland configuration, tracked in ~/workspace/dotfiles.
--
-- Omarchy owns hyprland.lua, bindings.lua, input.lua, looknfeel.lua, monitors.lua
-- and autostart.lua. Those are left stock so Omarchy's checksum-guarded migrations
-- keep updating them. Everything personal lives under hypr/jack/ instead, loaded
-- by a single require() appended to hyprland.lua.
--
-- Loaded after Omarchy's defaults, so these win.

require("hypr.jack.bindings")
require("hypr.jack.input")
require("hypr.jack.looknfeel")
