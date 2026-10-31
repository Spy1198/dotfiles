#!/usr/bin/env python3
import os, re, subprocess, sys
H = os.path.expanduser("~")
T = f"{H}/.config/themes"
name = sys.argv[1] if len(sys.argv) > 1 else open(f"{T}/.current").read().strip()
P = {}
for line in open(f"{T}/{name}.sh"):
    m = re.match(r'^([A-Z0-9_]+)=(.*)$', line.strip())
    if m:
        P[m.group(1)] = m.group(2).strip('"')
d = f"{H}/.config/spicetify/Themes/neon"
os.makedirs(d, exist_ok=True)
open(f"{d}/user.css", "a").close()
ini = f"""[neon]
text = {P['FG']}
subtext = {P['MUTED']}
main = {P['BG']}
main-elevated = {P['BG2']}
highlight = {P['BG2']}
highlight-elevated = {P['BG2']}
sidebar = {P['BG2']}
player = {P['BG2']}
card = {P['BG2']}
shadow = {P['BG']}
selected-row = {P['A1']}
button = {P['A1']}
button-active = {P['A1']}
button-disabled = {P['MUTED']}
tab-active = {P['A1']}
notification = {P['A2']}
notification-error = {P['ERR']}
equalizer = {P['A1']}
misc = {P['MUTED']}
"""
open(f"{d}/color.ini", "w").write(ini)
watching = subprocess.run(["pgrep", "-f", "spicetify watch"], capture_output=True).returncode == 0
if not watching:
    subprocess.Popen([f"{H}/.spicetify/spicetify", "apply", "-n"], start_new_session=True,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
print("spotify ok", name, "(live)" if watching else "(applied, restart Spotify)")
