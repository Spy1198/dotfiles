#!/usr/bin/env bash
LEFT="eDP-1"
RIGHT="HDMI-A-1"
OFFSET=10
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

sync() {
  sleep 0.15
  json=$(hyprctl monitors -j)
  focused=$(jq -r '.[]|select(.focused)|.name' <<<"$json")
  id=$(jq -r '.[]|select(.focused)|.activeWorkspace.id' <<<"$json")
  [ "$id" -gt 0 ] 2>/dev/null || return
  d=$(( (id - 1) % OFFSET + 1 ))
  if [ "$focused" = "$LEFT" ]; then other=$RIGHT; t=$((d + OFFSET))
  elif [ "$focused" = "$RIGHT" ]; then other=$LEFT; t=$d
  else return; fi
  oid=$(jq -r --arg m "$other" '.[]|select(.name==$m)|.activeWorkspace.id' <<<"$json")
  [ -z "$oid" ] && return
  [ "$oid" = "$t" ] && return
  hyprctl --batch "dispatch focusmonitor $other ; dispatch workspace $t ; dispatch focusmonitor $focused" >/dev/null
}

socat -U - "UNIX-CONNECT:$SOCK" | while read -r line; do
  case "$line" in
    workspacev2*) ( flock -n 9 && sync ) 9>/tmp/vdesk-sync.lock & ;;
  esac
done
