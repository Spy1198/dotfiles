#!/usr/bin/env bash
cur=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

choice=$(printf '%s\n' 100% 90% 80% 70% 60% 50% 40% 30% 20% 10% 5% "Custom..." \
  | rofi -dmenu -i -p "Brightness (now: ${cur}%)")
[ -z "$choice" ] && exit 0

if [ "$choice" = "Custom..." ]; then
  choice=$(rofi -dmenu -p "Brightness % (1-100)" < /dev/null)
  [ -z "$choice" ] && exit 0
  choice="${choice%\%}%"
fi

if [[ "$choice" =~ ^[0-9]+%$ ]]; then
  brightnessctl -n set "$choice" > /dev/null
  notify-send -t 1500 "Brightness" "Set to $choice"
else
  notify-send "Brightness" "Invalid value: $choice"
fi
