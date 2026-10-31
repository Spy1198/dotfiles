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
light = P.get("MODE") == "light"
g = lambda k, f: "#" + P.get(k, P[f])
BG, SIDE, RAISED = g("VD_BG", "BG"), g("VD_SIDE", "BG2"), g("VD_RAISED", "BG2")
TEXT, MUTED, ACC = g("VD_TEXT", "FG"), g("VD_MUTED", "MUTED"), g("VD_ACCENT", "A1")
LINK, ERR = "#" + P["A4"], "#" + P["ERR"]
ON = "#ffffff" if light else "#" + P["BG"]

V = {
    "--background-primary": BG, "--background-secondary": SIDE,
    "--background-secondary-alt": SIDE, "--background-tertiary": SIDE,
    "--background-base-lowest": SIDE, "--background-base-lower": SIDE,
    "--background-base-low": BG, "--background-surface-high": RAISED,
    "--background-floating": RAISED, "--background-mod-subtle": RAISED,
    "--background-mod-normal": RAISED, "--background-mod-strong": RAISED,
    "--chat-background-default": BG, "--channeltextarea-background": RAISED,
    "--input-background": RAISED,
    "--bg-base-primary": BG, "--bg-base-secondary": SIDE, "--bg-base-tertiary": SIDE,
    "--bg-surface-raised": RAISED, "--bg-surface-overlay": RAISED,
    "--text-normal": TEXT, "--text-default": TEXT, "--text-strong": TEXT,
    "--header-primary": TEXT, "--header-secondary": MUTED,
    "--text-muted": MUTED, "--text-secondary": MUTED, "--text-tertiary": MUTED,
    "--channels-default-name": TEXT, "--channels-default-label-color": MUTED,
    "--channel-icon": MUTED, "--interactive-muted": MUTED,
    "--interactive-normal": MUTED, "--interactive-hover": ACC, "--interactive-active": ACC,
    "--interactive-icon-default": MUTED, "--interactive-icon-hover": ACC,
    "--brand-500": ACC, "--brand-experiment": ACC, "--text-link": LINK,
    "--status-danger": ERR,
}
body = "\n".join(f"  {k}: {v} !important;" for k, v in V.items())
css = ":root, .theme-dark, .theme-light, .theme-darker, .theme-midnight {\n" + body + "\n}\n"
css += f'''
[class*="sidebar_"], [class*="panels_"], [class*="guilds_"], [class*="members_"],
[class*="userProfileOuter"], [class*="profilePanel"], [class*="userPanelOuter"] {{ background: {SIDE} !important; }}
[class*="chatContent_"] {{ background: {BG} !important; }}
[class*="title_"][class*="container_"] {{ background: {SIDE} !important; }}
[class*="markup_"], [class*="messageContent_"] {{ color: {TEXT} !important; }}
[class*="username_"] {{ color: {ACC} !important; }}
[class*="timestamp_"], [class*="repliedTextContent_"] {{ color: {MUTED} !important; }}
[class*="searchBar_"], [class*="channelTextArea_"], [class*="scrollableContainer_"] {{
  background: {RAISED} !important; color: {TEXT} !important; border-radius: 12px;
}}
[class*="placeholder_"] {{ color: {MUTED} !important; }}
[class*="lookFilled"], [class*="userProfile"] button, [class*="userProfile"] [role="button"] {{
  background: {ACC} !important; color: {ON} !important; border-radius: 10px;
}}
[class*="vc-rdb"], [class*="vc-rdb"] * {{ background-color: {RAISED} !important; color: {TEXT} !important; }}
'''
css += open(f"{H}/.config/themes/vesktop-extra.css").read().replace("@BG@", BG).replace("@TEXT@", TEXT).replace("@SIDE@", SIDE).replace("@RAISED@", RAISED) if os.path.exists(f"{H}/.config/themes/vesktop-extra.css") else ""
os.makedirs(f"{H}/.config/vesktop/settings", exist_ok=True)
open(f"{H}/.config/vesktop/settings/quickCss.css", "w").write(css)
print("vesktop ok", name)
