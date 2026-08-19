-- Keybindings carried from the Omarchy 3.8.5 bindings.conf (archived 2026-08-18).
-- Everything else in that file is now an Omarchy 4 default, including the F9
-- push-to-talk dictation pair (see default/hypr/bindings/voxtype.lua).

o.bind("SUPER + SHIFT + Q", "Qute Browser", { launch = "qutebrowser" })
o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })

o.bind("CTRL + ALT + RIGHT", "Change workspace ->", hl.dsp.focus({ workspace = "e+1" }))
o.bind("CTRL + ALT + LEFT", "Change workspace <-", hl.dsp.focus({ workspace = "e-1" }))
