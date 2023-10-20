#!/usr/bin/env python3

import argparse
import subprocess
import time

def set_legacy_theme(mode):
    theme = "Adwaita-dark" if mode == "dark" else "Adwaita"
    print(f"Setting theme to {theme}")
    subprocess.run(["dconf", "write", "/org/gnome/desktop/interface/gtk-theme", f"'{theme}'"])

def set_neovim_background(mode):
    background = "dark" if mode == "dark" else "light"
    command = f"<Esc>:set background={background}<CR>"
    
    # Find the unix sockets for all running neovim instances and send the command to them
    sockets = subprocess.getoutput("nvr --serverlist").split("\n")

    for socket in sockets:
        print(f"Sending command to {socket}: '{command}'")
        subprocess.run(["nvim", "--server", socket, "--remote-send", f"'{command}'"], stdout=subprocess.DEVNULL)

def update_settings(mode):
    set_legacy_theme(mode)
    set_neovim_background(mode)

def set_system_theme(mode):
    subprocess.run(["dconf", "write", "/org/gnome/desktop/interface/color-scheme", f"'{mode}'"])

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--update', choices=['light', 'dark'], help='Update settings (regardless of system theme)')
    parser.add_argument('-t', '--theme', choices=['light', 'dark'], help='Set the system theme and update settings')
    args = parser.parse_args()

    last_mode = None

    while True:
        if args.update:
            mode = args.update
            update_settings(mode)
            break
        elif args.theme:
            mode = args.theme
            set_system_theme(mode)
            update_settings(mode)
            break
        else:
            output = subprocess.getoutput("dconf read /org/gnome/desktop/interface/color-scheme")
            is_dark = (output == "'prefer-dark'")
            mode = "dark" if is_dark else "light"

        if mode != last_mode:
            update_settings(mode)
            last_mode = mode

        time.sleep(1)  # Check every second


if __name__ == "__main__":
    main()
