#!/usr/bin/env bash
if pgrep -x hypridle > /dev/null; then
  pkill -x hypridle
  notify-send -t 2000 "Auto-lock" "OFF: the laptop will stay awake"
else
  setsid hypridle > /dev/null 2>&1 &
  notify-send -t 2000 "Auto-lock" "ON: locks after 5 min"
fi
