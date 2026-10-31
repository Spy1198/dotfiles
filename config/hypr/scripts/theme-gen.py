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

def rgb(h):
    return ", ".join(str(int(h[i:i+2], 16)) for i in (0, 2, 4))

def txt(cid):
    return "#" + P["PILL_TEXT"] if "PILL_TEXT" in P else col(role_of(cid))

def col(k):
    return "#" + P[k]

# ---------------- Waybar ----------------
cfg = json.load(open(f"{H}/.config/waybar/config"))
bars = cfg if isinstance(cfg, list) else [cfg]
mods, kids = [], []
for b in bars:
    for k in ("modules-left", "modules-center", "modules-right"):
        for m in b.get(k, []):
            mods.append(m)
            if m.startswith("group/"):
                kids += b.get(m, {}).get("modules", [])

ROLE = {"workspaces": "A1", "window": "A2", "clock": "A2", "network": "A4",
        "battery": "A3", "tray": "A1", "backlight": "A3", "temperature": "ERR"}

def role_of(cid):
    if cid in ROLE:
        return ROLE[cid]
    c = cid.lower()
    if "mic" in c:
        return "A2"
    if "bluetooth" in c:
        return "A1"
    if "pulse" in c or "audio" in c:
        return "A3"
    return "A1"

def css_id(n):
    base, _, suffix = n.partition("#")
    if suffix:
        return suffix, "#" + suffix
    if base.startswith("custom/"):
        cid = "custom-" + base[7:]
    elif base.startswith("group/"):
        cid = base[6:]
    else:
        cid = base.split("/")[-1]
    return cid, "#" + cid

pill = P.get("PILL", P["BG2"] if light else P["BG"])
alpha = P.get("PILL_ALPHA", "0.92")
bg = f"rgba({rgb(pill)}, {alpha})"
edge = "rgba(255, 255, 255, 0.45)" if light else None

css = f"""* {{
  font-family: "JetBrainsMono Nerd Font";
  font-size: 13px;
  border: none;
  border-radius: 0;
  min-height: 0;
}}
window#waybar {{ background: transparent; color: {col('FG')}; }}
tooltip {{ background: {col('BG')}; border: 1px solid {col('A1')}; border-radius: 10px; }}
tooltip label {{ color: {col('FG')}; }}
"""

seen = set()
for n in mods:
    cid, sel = css_id(n)
    if sel in seen:
        continue
    seen.add(sel)
    c = txt(cid)
    css += f"""
{sel} {{
  background: {bg};
  color: {c};
  border: 1px solid {edge or c};
  border-radius: 14px;
  padding: 3px 14px;
  margin: 0 4px;
}}
"""

for n in kids:
    cid, sel = css_id(n)
    if sel in seen:
        continue
    seen.add(sel)
    css += f"""
{sel} {{
  background: transparent;
  color: {txt(cid)};
  border: none;
  padding: 0 8px;
  margin: 0;
}}
"""

css += f"""
#workspaces {{ padding: 2px 6px; }}
#workspaces button {{ padding: 0 8px; margin: 0 2px; color: {col('MUTED')}; background: transparent; border-radius: 10px; }}
#workspaces button.active {{ color: {col('BG2') if light else col('BG')}; background: {col('A1')}; }}
#workspaces button.urgent {{ color: {col('BG')}; background: {col('ERR')}; }}
#workspaces button:hover {{ background: {col('BG')}; color: {col('A2')}; }}
#window.empty {{ background: transparent; border: none; padding: 0; margin: 0; }}
#battery.critical {{ color: {col('ERR')}; border-color: {col('ERR')}; }}
#network.disconnected {{ color: {col('ERR')}; }}
"""
open(f"{H}/.config/waybar/style.css", "w").write(css)

# ---------------- kitty ----------------
black = P["FG"] if light else P["BG2"]
white = P["MUTED"] if light else P["FG"]
pal = [black, P["ERR"], P["A4"], P["A3"], P["A1"], P["A2"], P["A1"], white]
bright = [P["MUTED"], P["ERR"], P["A4"], P["A3"], P["A1"], P["A2"], P["A1"], white]
k = f"""foreground #{P['FG']}
background #{P.get('KITTY_BG', P['BG'])}
background_opacity {P.get('KITTY_OPACITY', '1.0')}
cursor #{P['A1']}
cursor_text_color #{P['BG']}
selection_foreground #{P['BG']}
selection_background #{P['A1']}
url_color #{P['A4']}
active_border_color #{P['A1']}
inactive_border_color #{P['MUTED']}
"""
for i, v in enumerate(pal):
    k += f"color{i} #{v}\n"
for i, v in enumerate(bright):
    k += f"color{i+8} #{v}\n"
open(f"{H}/.config/kitty/theme.conf", "w").write(k)
print("ok", name)
