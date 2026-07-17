from gi.repository import Nautilus, GObject
import subprocess
import os
import shutil
import shlex

class OpenInTerminal(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self):
        super().__init__()

    def get_terminal_command(self):
        # 1. Try $TERMINAL environment variable
        term = os.environ.get('TERMINAL')
        if term:
            # We use shlex.split to handle cases where $TERMINAL has arguments
            cmd = shlex.split(term)
            if shutil.which(cmd[0]):
                return cmd
        
        # 2. Try common default terminals
        terminals = [
            'alacritty', 'kitty', 'wezterm', 'foot', 'gnome-terminal',
            'konsole', 'xfce4-terminal', 'terminator', 'xterm'
        ]
        for t in terminals:
            if shutil.which(t):
                return [t]
        
        return ['xterm'] # absolute fallback

    def launch_terminal(self, menu, window):
        path = os.path.expanduser("~")  # fallback
        try:
            location = window.get_location()
            if location:
                path = location.get_path()
        except Exception:
            pass
        
        cmd = self.get_terminal_command()
        
        try:
            # Running the terminal emulator in the desired directory
            subprocess.Popen(cmd, cwd=path)
        except Exception as e:
            print(f"Failed to launch terminal: {e}")

    def get_background_items(self, window, file=None):
        item = Nautilus.MenuItem(
            name="OpenInTerminal::OpenInTerminal",
            label="Open in Terminal",
            tip="Open this folder in the default terminal"
        )
        item.connect("activate", self.launch_terminal, window)
        return [item]
