#!/usr/bin/env bash
pkill -f "spicetify watch"
spotify-launcher -- --remote-debugging-port=9222 >/dev/null 2>&1 &
sleep 8
setsid "$HOME/.spicetify/spicetify" watch -s >/dev/null 2>&1 &
