#!/usr/bin/env bash
T="$HOME/.config/themes"
name=${1:-$(cat "$T/.current")}
. "$T/$name.sh"
if [ "$MODE" = light ]; then base=KvFlatLight; else base=KvFlat; fi
src=/usr/share/Kvantum/$base
[ -f "$src/$base.kvconfig" ] || { echo "missing $src"; exit 1; }
t="Neon$name"
K="$HOME/.config/Kvantum/$t"
mkdir -p "$K"
cp "$src/$base.svg" "$K/$t.svg"
awk '/^\[/{skip=($0=="[GeneralColors]")} !skip' "$src/$base.kvconfig" > "$K/$t.kvconfig"
VIEW=${VD_BG:-$BG}; SIDE=${VD_SIDE:-$BG2}; RAISED=${VD_RAISED:-$BG2}
TEXT=${VD_TEXT:-$FG}; MUTED=${VD_MUTED:-$MUTED}; ACC=${VD_ACCENT:-$A1}
if [ "$MODE" = light ]; then ON=ffffff; else ON=$BG; fi
cat >> "$K/$t.kvconfig" <<EOF

[GeneralColors]
window.color=#$SIDE
base.color=#$VIEW
alt.base.color=#$RAISED
button.color=#$RAISED
light.color=#$RAISED
mid.light.color=#$SIDE
dark.color=#$SIDE
mid.color=#$SIDE
highlight.color=#$ACC
inactive.highlight.color=#$MUTED
text.color=#$TEXT
window.text.color=#$TEXT
button.text.color=#$TEXT
disabled.text.color=#$MUTED
tooltip.base.color=#$RAISED
tooltip.text.color=#$TEXT
highlight.text.color=#$ON
link.color=#$A4
link.visited.color=#$A2
EOF
printf '[General]\ntheme=%s\n' "$t" > "$HOME/.config/Kvantum/kvantum.kvconfig"
echo "dolphin theme: $t"
