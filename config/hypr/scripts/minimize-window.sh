#!/bin/bash

STATE="$HOME/.cache/hypr-minimized"
mkdir -p "$HOME/.cache"

if [ -s "$STATE" ]; then
    LINE=$(tail -n 1 "$STATE")
    ADDR="${LINE%%|*}"
    WORKSPACE="${LINE#*|}"

    sed -i '$d' "$STATE"

    hyprctl dispatch movetoworkspacesilent "$WORKSPACE,address:$ADDR"
else
    WINDOW=$(hyprctl activewindow -j)
    ADDR=$(echo "$WINDOW" | jq -r '.address')
    WORKSPACE=$(echo "$WINDOW" | jq -r '.workspace.name')

    if [ -n "$ADDR" ] && [ "$ADDR" != "0x0" ]; then
        echo "$ADDR|$WORKSPACE" >> "$STATE"
        hyprctl dispatch movetoworkspacesilent "special:minimized,address:$ADDR"
    fi
fi
