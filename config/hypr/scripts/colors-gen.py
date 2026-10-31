#!/usr/bin/env python3
import os, re, shutil, subprocess, sys
H = os.path.expanduser("~")
T = f"{H}/.config/themes"
name = sys.argv[1] if len(sys.argv) > 1 else open(f"{T}/.current").read().strip()
P = {}
for line in open(f"{T}/{name}.sh"):
    m = re.match(r'^([A-Z0-9_]+)=(.*)$', line.strip())
    if m:
        P[m.group(1)] = m.group(2).strip('"')
light = P.get("MODE") == "light"
g = lambda k, f: P.get(k, P[f])
rgb = lambda h: ",".join(str(int(h[i:i+2], 16)) for i in (0, 2, 4))
VIEW, SIDE, RAISED = g("VD_BG", "BG"), g("VD_SIDE", "BG2"), g("VD_RAISED", "BG2")
TEXT, MUTED, ACC = P.get("DOLPHIN_TEXT", g("VD_TEXT", "FG")), g("VD_MUTED", "MUTED"), g("VD_ACCENT", "A1")
ON = "ffffff" if light else P["BG"]

def grp(bg, alt, fg):
    return {"BackgroundAlternate": alt, "BackgroundNormal": bg, "DecorationFocus": ACC,
            "DecorationHover": ACC, "ForegroundActive": ACC, "ForegroundInactive": MUTED,
            "ForegroundLink": P["A4"], "ForegroundNegative": P["ERR"],
            "ForegroundNeutral": P["A3"], "ForegroundNormal": fg,
            "ForegroundPositive": P["A4"], "ForegroundVisited": P["A2"]}

sel = grp(ACC, ACC, ON)
for k in ("ForegroundInactive", "ForegroundActive", "ForegroundLink", "ForegroundVisited"):
    sel[k] = ON
groups = {"Colors:View": grp(VIEW, RAISED, TEXT), "Colors:Window": grp(SIDE, RAISED, TEXT),
          "Colors:Button": grp(RAISED, SIDE, TEXT), "Colors:Tooltip": grp(RAISED, SIDE, TEXT),
          "Colors:Complementary": grp(SIDE, RAISED, TEXT), "Colors:Header": grp(SIDE, RAISED, TEXT),
          "Colors:Selection": sel}
cname = "Neon" + name.capitalize()
out = f"[General]\nColorScheme={cname}\nName={cname}\n\n"
for sec, vals in groups.items():
    out += f"[{sec}]\n" + "".join(f"{k}={rgb(v)}\n" for k, v in vals.items()) + "\n"
d = f"{H}/.local/share/color-schemes"
os.makedirs(d, exist_ok=True)
open(f"{d}/{cname}.colors", "w").write(out)
tool = shutil.which("plasma-apply-colorscheme")
if tool:
    subprocess.run([tool, cname], capture_output=True)
    print("applied with plasma-apply-colorscheme:", cname)
else:
    print("plasma-apply-colorscheme not found; scheme file written but not applied")
