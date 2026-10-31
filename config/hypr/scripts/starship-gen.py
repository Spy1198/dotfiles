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
c = lambda k: "#" + P[k]
s = f'''format = """
[╭─](bold {c("A1")})$username$directory
[╰─](bold {c("A2")})$character"""

[username]
show_always = true
style_user = "bold {c("A1")}"
format = "[$user]($style) "

[directory]
style = "bold {c("A4")}"
format = "in [$path]($style)"
truncation_length = 3
truncate_to_repo = false

[character]
success_symbol = "[✦](bold {c("A2")}) "
error_symbol = "[✦](bold {c("ERR")}) "
vimcmd_symbol = "[✦](bold {c("A4")}) "
'''
open(f"{H}/.config/starship.toml", "w").write(s)
print("starship ok", name)
