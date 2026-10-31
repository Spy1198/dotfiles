#!/usr/bin/env bash
json=$(pactl -f json list cards)
card=$(jq -r '.[]|select(.name|startswith("bluez_card"))|.name' <<<"$json" | head -n1)
[ -z "$card" ] && { notify-send "Bluetooth audio" "No Bluetooth audio device connected"; exit 1; }
active=$(jq -r --arg c "$card" '.[]|select(.name==$c)|.active_profile' <<<"$json")
choice=$(jq -r --arg c "$card" '.[]|select(.name==$c)|.profiles|to_entries[]|select(.value.available!=false)|"\(.key)   \(.value.description)"' <<<"$json" \
  | rofi -dmenu -i -p "BT audio (now: $active)" | awk '{print $1}')
[ -z "$choice" ] && exit 0
pactl set-card-profile "$card" "$choice" && notify-send "Bluetooth audio" "Switched to $choice"
