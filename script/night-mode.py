#!/usr/bin/env python3

import subprocess
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import os
import sys

class ReloadHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if event.src_path == sys.argv[0]:
            print("Script modified, reloading...")
            os.execv(sys.executable, ['python3'] + sys.argv)

def set_legacy_theme(mode):
    theme = "Adwaita-dark" if mode == "dark" else "Adwaita"
    print(f"Setting theme to {theme}")
    subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", theme])

def set_neovim_background(mode):
    background = "dark" if mode == "dark" else "light"
    command = f"<Esc>:set background={background}<CR>"
    
    # Find the unix sockets for all running neovim instances and send the command to them
    for socket in subprocess.getoutput("lsof -U 2>/dev/null | grep nvim | awk '/nvim\.[0-9]+\.[0-9]+/ {print $(NF-2)}'").split("\n"):
        print(f"Sending command to {socket}: '{command}'")
        subprocess.run(["nvim", "--server", socket, "--remote-send", f"'{command}'"])

def main():
    observer = Observer()
    handler = ReloadHandler()
    observer.schedule(handler, path=sys.argv[0], recursive=False)
    observer.start()

    last_mode = None

    try:
        while True:
            output = subprocess.getoutput("gsettings get org.gnome.desktop.interface color-scheme")
            is_dark = (output == "'prefer-dark'")
            mode = "dark" if is_dark else "light"

            if mode != last_mode:
                set_legacy_theme(mode)
                set_neovim_background(mode)
                last_mode = mode

            time.sleep(1)  # Check every second
    except KeyboardInterrupt:
        observer.stop()

    observer.join()

if __name__ == "__main__":
    main()
