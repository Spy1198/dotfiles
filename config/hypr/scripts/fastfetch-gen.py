#!/usr/bin/env python3
import os, re, sys
H = os.path.expanduser("~")
T = f"{H}/.config/themes"
name = sys.argv[1] if len(sys.argv) > 1 else open(f"{T}/.current").read().strip()
P = {}
for line in open(f"{T}/{name}.sh"):
    m = re.match(r'^([A-Z0-9_]+)=(.*)$', line.strip())
    if m:
        P[m.group(1)] = m.group(2).strip('"')
rgb = lambda k: "38;2;" + ";".join(str(int(P[k][i:i+2], 16)) for i in (0, 2, 4))
p = f"{H}/.config/fastfetch/config.jsonc"
s = open(p).read()
s = re.sub(r'("1":\s*")[^"]*(")', lambda m: m.group(1) + rgb("A2") + m.group(2), s)
s = re.sub(r'("keys":\s*")[^"]*(")', lambda m: m.group(1) + rgb("A1") + m.group(2), s)
s = re.sub(r'("output":\s*")[^"]*(")', lambda m: m.group(1) + rgb("FG") + m.group(2), s)
open(p, "w").write(s)
print("fastfetch ok", name)
