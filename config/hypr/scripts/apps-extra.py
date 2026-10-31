#!/usr/bin/env python3
import configparser, json, os, re, shutil, subprocess, sys

H = os.path.expanduser("~")
T = f"{H}/.config/themes"
name = sys.argv[1] if len(sys.argv) > 1 else open(f"{T}/.current").read().strip()
P = {}
for line in open(f"{T}/{name}.sh"):
    m = re.match(r'^([A-Z0-9_]+)=(.*)$', line.strip())
    if m:
        P[m.group(1)] = m.group(2).strip('"')
light = P.get("MODE") == "light"
hx = lambda k: "#" + P[k]
rgb = lambda k: ",".join(str(int(P[k][i:i+2], 16)) for i in (0, 2, 4))


def kde():
    p = f"{H}/.config/kdeglobals"
    if os.path.exists(p) and not os.path.exists(p + ".themebak"):
        shutil.copy(p, p + ".themebak")
    cp = configparser.RawConfigParser(delimiters=("=",), strict=False, allow_no_value=True)
    cp.optionxform = str
    try:
        if os.path.exists(p):
            cp.read(p, encoding="utf-8")
    except Exception as e:
        print("kde: could not parse kdeglobals, skipped:", e)
        return

    def grp(bg, alt, fg):
        return {"BackgroundNormal": rgb(bg), "BackgroundAlternate": rgb(alt),
                "ForegroundNormal": rgb(fg), "ForegroundInactive": rgb("MUTED"),
                "ForegroundActive": rgb("A1"), "ForegroundLink": rgb("A4"),
                "ForegroundVisited": rgb("A2"), "ForegroundNegative": rgb("ERR"),
                "ForegroundNeutral": rgb("A3"), "ForegroundPositive": rgb("A4"),
                "DecorationFocus": rgb("A1"), "DecorationHover": rgb("A1")}

    sel = grp("A1", "A1", "BG")
    for k in ("ForegroundInactive", "ForegroundActive", "ForegroundLink", "ForegroundVisited"):
        sel[k] = rgb("BG")
    sets = {"Colors:Window": grp("BG", "BG2", "FG"),
            "Colors:View": grp("BG", "BG2", "FG"),
            "Colors:Button": grp("BG2", "BG", "FG"),
            "Colors:Tooltip": grp("BG2", "BG", "FG"),
            "Colors:Complementary": grp("BG", "BG2", "FG"),
            "Colors:Header": grp("BG2", "BG", "FG"),
            "Colors:Selection": sel}
    for sec, vals in sets.items():
        if not cp.has_section(sec):
            cp.add_section(sec)
        for k, v in vals.items():
            cp.set(sec, k, v)
    if not cp.has_section("General"):
        cp.add_section("General")
    cp.set("General", "ColorScheme", "Neon")
    with open(p, "w", encoding="utf-8") as f:
        cp.write(f, space_around_delimiters=False)
    try:
        subprocess.run(["dbus-send", "--session", "--type=signal", "/KGlobalSettings",
                        "org.kde.KGlobalSettings.notifyChange", "int32:0", "int32:0"],
                       capture_output=True)
    except Exception:
        pass
    print("kde ok")


def vscode():
    done = False
    for d in ("Code", "Code - OSS", "VSCodium", "Antigravity IDE"):
        p = f"{H}/.config/{d}/User/settings.json"
        if not os.path.exists(p):
            continue
        if not os.path.exists(p + ".themebak"):
            shutil.copy(p, p + ".themebak")
        try:
            raw = open(p, encoding="utf-8").read()
            s = json.loads(raw) if raw.strip() else {}
        except Exception:
            print("vscode: settings.json has comments or errors, skipped:", p)
            continue
        s["workbench.colorTheme"] = "Default Light Modern" if light else "Default Dark Modern"
        s["workbench.colorCustomizations"] = {
            "editor.background": hx("BG"), "editor.foreground": hx("FG"),
            "editorCursor.foreground": hx("A1"),
            "editor.selectionBackground": hx("A1") + "55",
            "editorLineNumber.foreground": hx("MUTED"),
            "editorLineNumber.activeForeground": hx("A1"),
            "sideBar.background": hx("BG2"), "sideBar.foreground": hx("FG"),
            "activityBar.background": hx("BG2"), "activityBar.foreground": hx("A1"),
            "activityBar.inactiveForeground": hx("MUTED"),
            "activityBarBadge.background": hx("A2"), "activityBarBadge.foreground": hx("BG"),
            "titleBar.activeBackground": hx("BG2"), "titleBar.activeForeground": hx("FG"),
            "titleBar.inactiveBackground": hx("BG2"),
            "statusBar.background": hx("A1"), "statusBar.foreground": hx("BG"),
            "tab.activeBackground": hx("BG"), "tab.activeForeground": hx("A1"),
            "tab.inactiveBackground": hx("BG2"), "tab.inactiveForeground": hx("MUTED"),
            "editorGroupHeader.tabsBackground": hx("BG2"),
            "panel.background": hx("BG"),
            "terminal.background": hx("BG"), "terminal.foreground": hx("FG"),
            "focusBorder": hx("A1"),
            "button.background": hx("A1"), "button.foreground": hx("BG"),
            "input.background": hx("BG2"), "input.foreground": hx("FG"),
            "list.hoverBackground": hx("BG2"),
            "list.activeSelectionBackground": hx("A1") + "55",
            "textLink.foreground": hx("A4"),
            "badge.background": hx("A2"), "badge.foreground": hx("BG"),
        }
        with open(p, "w", encoding="utf-8") as f:
            json.dump(s, f, indent=4)
        print("vscode ok:", p)
        done = True
    if not done:
        print("vscode: no settings.json found")


def brave():
    p = "/etc/brave/policies/managed/theme.json"
    if not os.path.exists(p) or not os.access(p, os.W_OK):
        print("brave: policy file missing or not writable, skipped")
        return
    json.dump({"BrowserThemeColor": hx("PILL" if "PILL" in P else "BG"),
               }, open(p, "w"))
    print("brave ok")


for fn in (kde, vscode, brave):
    try:
        fn()
    except Exception as e:
        print(fn.__name__, "failed:", e)
