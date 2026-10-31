#!/bin/bash

STATE="$HOME/.cache/hypr-show-desktop"
mkdir -p "$HOME/.cache"

if [ -f "$STATE" ]; then
    while IFS='|' read -r addr workspace; do
        hyprctl dispatch movetoworkspacesilent "$workspace,address:$addr"
    done < "$STATE"

    rm -f "$STATE"
else
    : > "$STATE"

    hyprctl clients -j | jq -r '
        .[]
        | select(.workspace.name != "special:desktop")
        | select(.workspace.id >= 1)
        | "\(.address)|\(.workspace.name)"
    ' > "$STATE"

    while IFS='|' read -r addr workspace; do
        hyprctl dispatch movetoworkspacesilent "special:desktop,address:$addr"
    done < "$STATE"
fi
