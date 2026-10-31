#!/usr/bin/env bash
# usage: theme.sh cyberpunk|macos|red|green   or   theme.sh restore
T="$HOME/.config/themes"
STATE="$T/.current"
mkdir -p "$T/backup"
[ -f "$STATE" ] || echo cyberpunk > "$STATE"
cur=$(cat "$STATE")

mode=switch
if [ "$1" = restore ]; then mode=restore; name=$cur; else name=$1; fi
[ -f "$T/$name.sh" ] || { notify-send "Theme" "Unknown theme: $name"; exit 1; }

ROLES=(BG BG2 FG A1 A2 A3 A4 ERR MUTED)
load() { ( . "$T/$1.sh"; for r in "${ROLES[@]}"; do echo "${!r}"; done ); }
rgb() { printf '%d, %d, %d' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }

. "$T/$name.sh"

if [ "$mode" = switch ]; then
  mapfile -t OLD < <(load "$cur")
  mapfile -t NEW < <(load "$name")
  S=""; E=""
  for i in "${!ROLES[@]}"; do
    o=${OLD[$i]}; n=${NEW[$i]}
    S+="s/$o/@@H$i@@/Ig;s/$(rgb "$o" | sed 's/, /, */g')/@@R$i@@/g;"
    E+="s/@@H$i@@/$n/g;s/@@R$i@@/$(rgb "$n")/g;"
  done

  FILES=(
    "$HOME/.config/waybar/style.css"
    "$HOME/.config/kitty/kitty.conf"
    "$HOME/.config/alacritty/neon-popup.toml"
    "$HOME/.config/hypr/hyprlock.conf"
    "$HOME/.config/hypr/scripts/power-panel.py"
    "$HOME/.config/hypr/scripts/screenshot.sh"
    "$HOME/.config/swaync/style.css"
  )
  for f in "$HOME"/.config/rofi/*.rasi; do FILES+=("$f"); done

  for f in "${FILES[@]}"; do
    [ -f "$f" ] || continue
    b="$T/backup/$(echo "$f" | tr / _)"
    [ -f "$b" ] || cp "$f" "$b"
    sed -i "$S$E" "$f"
  done
  echo "$name" > "$STATE"
fi

# Hyprland overrides, loaded by 'source' at the end of hyprland.conf
cat > "$HOME/.config/hypr/theme.conf" <<EOF
general:col.active_border = $ACTIVE_BORDER
general:col.inactive_border = $INACTIVE_BORDER
general:border_size = $BORDER_SIZE
general:gaps_in = $GAPS_IN
general:gaps_out = $GAPS_OUT
decoration:rounding = $ROUNDING
decoration:shadow:color = $SHADOW_COLOR
decoration:shadow:range = $SHADOW_RANGE
EOF
echo "$RAIN_RGB" > "$HOME/.config/hypr/rain-color"

start_rain() {
  env LD_PRELOAD=/usr/lib/libgtk4-layer-shell.so setsid python3 "$HOME/.config/hypr/scripts/rain.py" >/dev/null 2>&1 &
}
if [ "$RAIN" = on ]; then
  if [ "$mode" = switch ]; then pkill -f rain.py; sleep 0.3; start_rain
  else pgrep -f rain.py >/dev/null || start_rain; fi
else
  pkill -f rain.py
fi

W="$HOME/Pictures/Wallpapers/$WALL"
if [ -f "$W" ]; then awww img --resize crop "$W"; else notify-send "Theme" "Wallpaper missing: $W"; fi

if [ "$mode" = switch ]; then
  if command -v fish >/dev/null; then
    fish -c "set -U fish_color_command $A1; set -U fish_color_param $FG; set -U fish_color_error $ERR; set -U fish_color_quote $A2; set -U fish_color_operator $A2; set -U fish_color_comment $MUTED; set -U fish_color_autosuggestion $MUTED"
  fi
  python3 "$HOME/.config/hypr/scripts/theme-gen.py" "$name"
  python3 "$HOME/.config/hypr/scripts/starship-gen.py" "$name"
  python3 "$HOME/.config/hypr/scripts/fastfetch-gen.py" "$name"
  hyprctl reload >/dev/null
  pkill -USR1 -x kitty
  swaync-client -rs >/dev/null 2>&1
  pkill -x waybar; sleep 0.3; setsid waybar >/dev/null 2>&1 &
  ~/.config/hypr/scripts/theme-extras.sh "$name"
  notify-send -t 1500 "Theme" "$name"
fi

"$HOME/.config/hypr/scripts/apps-theme.sh" "$name" >/dev/null 2>&1
python3 "$HOME/.config/hypr/scripts/apps-extra.py" "$name" >/dev/null 2>&1
python3 "$HOME/.config/hypr/scripts/spotify-gen.py" "$name" >/dev/null 2>&1
python3 "$HOME/.config/hypr/scripts/vesktop-gen.py" "$name" >/dev/null 2>&1
"$HOME/.config/hypr/scripts/dolphin-gen.sh" "$name" >/dev/null 2>&1
"$HOME/.config/hypr/scripts/dolphin-text.sh" "$name" >/dev/null 2>&1
if pgrep -x dolphin >/dev/null; then pkill -x dolphin; sleep 0.7; setsid dolphin >/dev/null 2>&1 & fi
