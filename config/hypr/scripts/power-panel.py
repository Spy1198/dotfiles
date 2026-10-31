#!/usr/bin/env python3
import glob
import subprocess
import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, Gdk, GLib

def run(*args):
    return subprocess.run(args, capture_output=True, text=True).stdout.strip()

def get_brightness():
    try:
        return int(run("brightnessctl", "-m").split(",")[3].rstrip("%"))
    except Exception:
        return 50

def get_battery():
    for p in glob.glob("/sys/class/power_supply/BAT*/capacity"):
        try:
            return int(open(p).read().strip())
        except Exception:
            pass
    return None

def idle_running():
    return subprocess.run(["pgrep", "-x", "hypridle"], capture_output=True).returncode == 0

CSS = """
window { background: #0d0221; border: 2px solid #00f0ff; border-radius: 14px; }
label { color: #00f0ff; font-family: "JetBrainsMono Nerd Font"; font-size: 14px; }
label.title { color: #ff00a0; font-size: 16px; font-weight: bold; }
scale trough { background: #1a0b3d; min-height: 8px; border-radius: 6px; }
scale highlight { background: #ff00a0; border-radius: 6px; }
scale slider { background: #00f0ff; min-width: 18px; min-height: 18px; border-radius: 9px; }
scale value { color: #00f0ff; }
switch { background: #1a0b3d; border: 1px solid #00f0ff; }
switch:checked { background: #ff00a0; }
switch slider { background: #00f0ff; }
"""

class Panel(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="local.powerpanel")
        self.pending = None

    def do_activate(self):
        win = Gtk.ApplicationWindow(application=self)
        win.set_title("Power")
        win.set_decorated(False)
        win.set_resizable(False)
        win.set_default_size(340, -1)

        css = Gtk.CssProvider()
        css.load_from_string(CSS)
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        for side in ("top", "bottom", "start", "end"):
            getattr(box, "set_margin_" + side)(20)

        bat = get_battery()
        title = Gtk.Label(label="Power" if bat is None else f"Battery {bat}%", xalign=0)
        title.add_css_class("title")
        box.append(title)

        box.append(Gtk.Label(label="Brightness", xalign=0))
        scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 1, 100, 1)
        scale.set_value(get_brightness())
        scale.set_draw_value(True)
        scale.set_value_pos(Gtk.PositionType.RIGHT)
        scale.set_hexpand(True)
        scale.connect("value-changed", self.on_brightness)
        box.append(scale)

        row = Gtk.Box(spacing=12)
        lbl = Gtk.Label(label="Auto-lock", xalign=0)
        lbl.set_hexpand(True)
        sw = Gtk.Switch()
        sw.set_active(idle_running())
        sw.set_valign(Gtk.Align.CENTER)
        sw.connect("notify::active", self.on_autolock)
        row.append(lbl)
        row.append(sw)
        box.append(row)

        win.set_child(box)

        keys = Gtk.EventControllerKey()
        keys.connect("key-pressed", lambda c, k, kc, m: win.close() if k == Gdk.KEY_Escape else None)
        win.add_controller(keys)

        # close when clicking away, but only after the window has had time to get focus
        def arm():
            win.connect("notify::is-active", lambda w, p: None if w.is_active() else w.close())
            return False
        GLib.timeout_add(700, arm)

        win.present()

    def on_brightness(self, scale):
        if self.pending:
            GLib.source_remove(self.pending)
        value = int(scale.get_value())
        def apply():
            subprocess.Popen(["brightnessctl", "-n", "set", f"{value}%"],
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            self.pending = None
            return False
        self.pending = GLib.timeout_add(60, apply)

    def on_autolock(self, sw, _param):
        if sw.get_active():
            if not idle_running():
                subprocess.Popen(["hypridle"], start_new_session=True,
                                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            subprocess.run(["pkill", "-x", "hypridle"])

Panel().run()
