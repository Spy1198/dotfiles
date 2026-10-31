#!/usr/bin/env bash
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
region=$(slurp -b 00000000 -c 00f0ffff -s 00000000 -w 2) || exit 0
f="$dir/$(date +%F_%H-%M-%S).png"
grim -g "$region" - | satty --filename - --output-filename "$f" --copy-command wl-copy --early-exit --initial-tool arrow
