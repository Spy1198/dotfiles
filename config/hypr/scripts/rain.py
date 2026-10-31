#!/usr/bin/env python3
import random
import cairo
import gi
gi.require_version("Gtk", "4.0")
gi.require_version("Gtk4LayerShell", "1.0")
from gi.repository import Gtk, Gdk, GLib, Gtk4LayerShell as LS

N = 160  # number of drops; lower it if it feels heavy

def load_color():
    try:
        return [float(x) for x in open("__HOME__/.config/hypr/rain-color").read().split()][:3]
    except Exception:
        return [0.0, 0.94, 1.0]

COLOR = load_color()

class Rain(Gtk.DrawingArea):
    def __init__(self):
        super().__init__()
        self.w, self.h = 1920, 1080
        self.drops = [self.new(True) for _ in range(N)]
        self.set_draw_func(self.draw)
        GLib.timeout_add(33, self.tick)  # about 30 fps

    def new(self, anywhere=False):
        y = random.uniform(0, self.h) if anywhere else random.uniform(-300, 0)
        # x, y, speed, length, alpha
        return [random.uniform(0, self.w), y, random.uniform(14, 30),
                random.uniform(12, 30), random.uniform(0.12, 0.45)]

    def tick(self):
        for d in self.drops:
            d[1] += d[2]
            d[0] += d[2] * 0.12  # slight slant
            if d[1] > self.h:
                d[:] = self.new()
        self.queue_draw()
        return True

    def draw(self, area, cr, w, h):
        self.w, self.h = w, h
        cr.set_line_width(1.3)
        for x, y, s, l, a in self.drops:
            cr.set_source_rgba(COLOR[0], COLOR[1], COLOR[2], a)
            cr.move_to(x, y)
            cr.line_to(x + l * 0.12, y + l)
            cr.stroke()

def activate(app):
    css = Gtk.CssProvider()
    css.load_from_string("window, window.background, .background { background: transparent; background-color: transparent; }")
    Gtk.StyleContext.add_provider_for_display(
        Gdk.Display.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_USER)
    mons = Gdk.Display.get_default().get_monitors()
    for i in range(mons.get_n_items()):
        win = Gtk.Window(application=app)
        LS.init_for_window(win)
        LS.set_namespace(win, "rain")
        LS.set_layer(win, LS.Layer.BOTTOM)  # above wallpaper, below windows
        LS.set_monitor(win, mons.get_item(i))
        for edge in (LS.Edge.TOP, LS.Edge.BOTTOM, LS.Edge.LEFT, LS.Edge.RIGHT):
            LS.set_anchor(win, edge, True)
        LS.set_exclusive_zone(win, -1)
        LS.set_keyboard_mode(win, LS.KeyboardMode.NONE)
        win.set_child(Rain())
        win.connect("map", lambda w: w.get_surface().set_input_region(cairo.Region()))  # click-through
        win.present()

app = Gtk.Application(application_id="local.rain")
app.connect("activate", activate)
app.run()
