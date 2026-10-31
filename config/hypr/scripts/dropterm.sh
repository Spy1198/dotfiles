#!/usr/bin/env bash
CLASS=dropterm
exists() { hyprctl clients -j | jq -e --arg c "$CLASS" 'any(.[]; .class==$c)' >/dev/null; }

if ! exists; then
  setsid kitty --class "$CLASS" >/dev/null 2>&1 &
  for i in $(seq 1 40); do
    exists && break
    sleep 0.1
  done
  hyprctl dispatch movetoworkspacesilent "special:$CLASS,class:$CLASS" >/dev/null
fi
hyprctl dispatch togglespecialworkspace "$CLASS" >/dev/null
