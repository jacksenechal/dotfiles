#!/bin/bash

set -e
set -x

# Define the primary modifier combination
MODIFIER="<Control><Alt><Super>"

# Configure keybindings
gsettings set org.gnome.desktop.wm.keybindings raise "['${MODIFIER}<Shift>Up']"
gsettings set org.gnome.desktop.wm.keybindings lower "['${MODIFIER}<Shift>Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-center "['${MODIFIER}c']"
gsettings set org.gnome.desktop.wm.keybindings maximize-horizontally "['${MODIFIER}h']"
gsettings set org.gnome.desktop.wm.keybindings maximize-vertically "['${MODIFIER}v']"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['${MODIFIER}m']"
gsettings set org.gnome.desktop.wm.keybindings begin-move "['${MODIFIER}Return']"
gsettings set org.gnome.desktop.wm.keybindings begin-resize "['${MODIFIER}<Shift>Return']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-nw "['${MODIFIER}1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-ne "['${MODIFIER}2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-sw "['${MODIFIER}3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-se "['${MODIFIER}4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-side-n "['${MODIFIER}Up']"
gsettings set org.gnome.desktop.wm.keybindings move-to-side-s "['${MODIFIER}Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-side-e "['${MODIFIER}Right']"
gsettings set org.gnome.desktop.wm.keybindings move-to-side-w "['${MODIFIER}Left']"

# open gnome terminal the old way
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'open-terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Control><Alt>t'

# ## Harlan's tiling keybindings

# Ctrl+Alt+Super+M        Maximize
# Ctrl+Alt+Super+Left     Left half of screen
# Ctrl+Alt+Super+Right    Right half of screen
# Ctrl+Alt+Super+Left x2  Left third of screen
# Ctrl+Alt+Super+Right x2 Right third of screen
# Ctrl+Alt+Super+1,2,3,4  Quadrants
# Ctrl+Alt+Super+5-0      Sixths
# Ctrl+Alt+Super+T        Cycle through full-height thirds
# Ctrl+Alt+Super+F        Cycle through full-height fourths
# Ctrl+Alt+Super+C        Center window
# Ctrl+Alt+Super++        Grow window
# Ctrl+Alt+Super+-        Shrink window


# ---------------------------------------------------------------------------

# Other settings
gsettings set org.gnome.shell.app-switcher current-workspace-only true
gsettings set org.gnome.shell.window-switcher current-workspace-only true
