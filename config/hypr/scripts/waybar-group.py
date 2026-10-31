#!/usr/bin/env python3
import json, os
p = os.path.expanduser("~/.config/waybar/config")
cfg = json.load(open(p))
bars = cfg if isinstance(cfg, list) else [cfg]
for b in bars:
    for side in ("modules-left", "modules-center", "modules-right"):
        b[side] = [m for m in b.get(side, [])
                   if m.split("#")[0].split("/")[-1] not in ("cpu", "memory")]
    right = b.get("modules-right", [])
    keys = ("bluetooth", "pulse", "audio", "mic", "wireplumber")
    pick = [m for m in right if any(k in m.lower() for k in keys)]
    print("grouping:", pick)
    if not pick:
        continue
    idx = min(right.index(m) for m in pick)
    lead = next((m for m in pick if "pulse" in m.lower() and "mic" not in m.lower()), pick[0])
    pick.remove(lead)
    pick.insert(0, lead)
    new = [m for m in right if m not in pick]
    new.insert(idx, "group/audio")
    b["modules-right"] = new
    b["group/audio"] = {
        "orientation": "inherit",
        "drawer": {"transition-duration": 300, "transition-left-to-right": False},
        "modules": pick,
    }
json.dump(cfg, open(p, "w"), indent=2)
print("ok")
