#!/usr/bin/env bash
# usage: vdesk.sh go N | next | prev | grow | shrink | movenext | moveprev
LEFT="eDP-1"
RIGHT="HDMI-A-1"
OFFSET=10
STATE="$HOME/.cache/vdesk_max"
[ -f "$STATE" ] || echo 6 > "$STATE"
MAX=$(cat "$STATE")

monitors=$(hyprctl monitors -j)
has() { jq -e --arg m "$1" 'any(.[]; .name==$m)' <<<"$monitors" >/dev/null; }

focused=$(jq -r '.[]|select(.focused)|.name' <<<"$monitors")
id=$(jq -r '.[]|select(.focused)|.activeWorkspace.id' <<<"$monitors")
cur=$(( (id - 1) % OFFSET + 1 ))

goto() {
  d=$1
  if has "$LEFT" && has "$RIGHT"; then
    hyprctl --batch "dispatch focusmonitor $LEFT ; dispatch workspace $d ; dispatch focusmonitor $RIGHT ; dispatch workspace $((d+OFFSET)) ; dispatch focusmonitor $focused"
  elif has "$LEFT"; then
    hyprctl dispatch workspace "$d"
  else
    hyprctl dispatch workspace "$((d+OFFSET))"
  fi
}

move_to() {
  d=$1
  if [ "$focused" = "$RIGHT" ]; then t=$((d + OFFSET)); else t=$d; fi
  hyprctl dispatch movetoworkspace "$t"
  goto "$d"
}

case "$1" in
  go)       goto "$2" ;;
  next)     goto $(( cur % MAX + 1 )) ;;
  prev)     goto $(( (cur + MAX - 2) % MAX + 1 )) ;;
  movenext) move_to $(( cur % MAX + 1 )) ;;
  moveprev) move_to $(( (cur + MAX - 2) % MAX + 1 )) ;;
  grow)     [ "$MAX" -lt 10 ] && echo $((MAX+1)) > "$STATE"; goto $((MAX+1 > 10 ? 10 : MAX+1)) ;;
  shrink)   [ "$MAX" -gt 1 ] && echo $((MAX-1)) > "$STATE"; goto 1 ;;
esac
