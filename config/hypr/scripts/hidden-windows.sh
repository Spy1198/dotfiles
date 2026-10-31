#!/bin/bash

DESKTOP_STATE="$HOME/.cache/hypr-show-desktop"
MIN_STATE="$HOME/.cache/hypr-minimized"

declare -A TARGETS

if [ -f "$DESKTOP_STATE" ]; then
    while IFS='|' read -r addr workspace; do
        [ -n "$addr" ] && TARGETS["$addr"]="$workspace"
    done < "$DESKTOP_STATE"
fi

if [ -f "$MIN_STATE" ]; then
    while IFS='|' read -r addr workspace; do
        [ -n "$addr" ] && TARGETS["$addr"]="$workspace"
    done < "$MIN_STATE"
fi

LIST=""

while IFS=$'\t' read -r addr class title workspace; do
    [ -z "$addr" ] && continue

    case "$workspace" in
        special:*)
            target="${TARGETS[$addr]}"
            [ -z "$target" ] && target="1"

            label="$class  |  $title  |  → workspace $target"
            LIST+="$label"$'\t'"$addr"$'\t'"$target"$'\n'
            ;;
    esac
done < <(
    hyprctl clients -j |
    jq -r '.[] | [.address, .class, .title, .workspace.name] | @tsv'
)

if [ -z "$LIST" ]; then
    notify-send "Hidden Windows" "No hidden windows"
    exit 0
fi

CHOICE=$(printf '%s' "$LIST" |
    cut -f1 |
    rofi -dmenu \
        -i \
        -p "Hidden Windows" \
        -theme-str 'window { width: 700px; } listview { lines: 8; }')

[ -z "$CHOICE" ] && exit 0

ENTRY=$(printf '%s' "$LIST" | grep -F "$CHOICE"$'\t' | head -n1)

ADDR=$(printf '%s' "$ENTRY" | cut -f2)
TARGET=$(printf '%s' "$ENTRY" | cut -f3)

[ -z "$ADDR" ] && exit 0

hyprctl dispatch movetoworkspacesilent "$TARGET,address:$ADDR"

if [ -f "$DESKTOP_STATE" ]; then
    sed -i "/^$ADDR|/d" "$DESKTOP_STATE"
fi

if [ -f "$MIN_STATE" ]; then
    sed -i "/^$ADDR|/d" "$MIN_STATE"
fi

hyprctl dispatch focuswindow "address:$ADDR"
