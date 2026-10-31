#!/usr/bin/env bash
PIDF=/tmp/autoclick.pid
MIN=14
MAX=16
export YDOTOOL_SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/.ydotool_socket"

in_game() {
  hyprctl activewindow -j | jq -r '.class' | grep -qi -E 'lunar|minecraft|moonsworth|badlion'
}

# already running: stop it
if [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
  kill "$(cat "$PIDF")"
  rm -f "$PIDF"
  exit 0
fi

# only start while the game is focused
in_game || exit 0

(
  lo=$((MIN * 10))
  span=$(( (MAX - MIN) * 10 + 1 ))
  next=${EPOCHREALTIME/[.,]/}
  n=0
  while true; do
    ydotool click 0xC0
    n=$((n + 1))
    if [ $((n % 40)) -eq 0 ] && ! in_game; then rm -f "$PIDF"; exit 0; fi

    cps10=$(( lo + RANDOM % span ))
    next=$(( next + 10000000 / cps10 ))
    now=${EPOCHREALTIME/[.,]/}
    rem=$(( next - now ))
    if [ "$rem" -gt 0 ]; then
      printf -v s '0.%06d' "$rem"
      sleep "$s"
    elif [ "$rem" -lt -150000 ]; then
      next=$now
    fi
  done
) &
echo $! > "$PIDF"
