#!/usr/bin/env python3
import json, os, re, sys
H = os.path.expanduser("~")
T = f"{H}/.config/themes"
name = sys.argv[1] if len(sys.argv) > 1 else open(f"{T}/.current").read().strip()
P = {}
for line in open(f"{T}/{name}.sh"):
    m = re.match(r'^([A-Z0-9_]+)=(.*)$', line.strip())
    if m:
        P[m.group(1)] = m.group(2).strip('"')
light = P.get("MODE") == "light"
rgb = lambda h: [int(h[i:i+2], 16) for i in (0, 2, 4)]
mix = lambda a, b, t: [round(x * t + y * (1 - t)) for x, y in zip(rgb(a), rgb(b))]

if light:
    active = rgb(P.get("PILL", P["BG2"]))
    inactive = rgb(P["BG"])
    text = rgb(P.get("PILL_TEXT", P["FG"]))
else:
    active = mix(P["A1"], P["BG"], 0.45)   # highlighted tab
    inactive = rgb(P["BG"])                # dark tabs
    text = rgb(P["FG"])

d = f"{H}/.config/brave-neon-theme"
os.makedirs(d, exist_ok=True)
json.dump({
    "manifest_version": 3,
    "name": "Neon " + name,
    "version": str(int.from_bytes(os.urandom(2), "big") % 60000 + 1) + ".0",
    "theme": {"colors": {
        "frame": inactive, "frame_inactive": inactive,
        "toolbar": active, "background_tab": inactive,
        "tab_text": text, "tab_background_text": text,
        "bookmark_text": text,
    }},
}, open(f"{d}/manifest.json", "w"), indent=2)
print("brave theme ok", name)
