#!/usr/bin/env bash
T="$HOME/.config/themes"
name=${1:-$(cat "$T/.current")}
. "$T/$name.sh"
[ -n "$DOLPHIN_TEXT" ] || exit 0
f="$HOME/.config/Kvantum/Neon$name/Neon$name.kvconfig"
[ -f "$f" ] || exit 1
awk -v c="#$DOLPHIN_TEXT" '
/^\[/ {
  if ($0 == "[ItemView]") {
    n++
    if (n > 1) { skip = 1; next }
    skip = 0; insec = 1
    print
    print "text.normal.color=" c
    print "text.focus.color=" c
    print "text.press.color=#ffffff"
    print "text.toggle.color=#ffffff"
    next
  } else { skip = 0; insec = 0 }
}
skip { next }
insec && /^text\.(normal|focus|press|toggle)\.color=/ { next }
{ print }
' "$f" > "$f.new" && mv "$f.new" "$f"
echo "dolphin text: #$DOLPHIN_TEXT"
printf "[General]\ntheme=Neon%s\n" "$name" > "$HOME/.config/Kvantum/kvantum.kvconfig"
