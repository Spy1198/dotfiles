#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"

command -v rsync >/dev/null || { echo "Install rsync first: sudo pacman -S rsync"; exit 1; }

for dir in "$REPO"/config/*/; do
  name="$(basename "$dir")"
  if [ ! -d "$CONF/$name" ]; then
    echo "skip $name (not found in $CONF)"
    continue
  fi
  rsync -a --delete \
    --exclude='*.bak' --exclude='*.bak[0-9]*' --exclude='*.pre-cleanup' --exclude='*.bak*' \
    --exclude='*.kvconfig.txt' --exclude='*.log' --exclude='backup/' \
    --exclude='.current' --exclude='theme.conf' --exclude='rain-color' \
    "$CONF/$name/" "$dir"
done

grep -rIl --null "$HOME" "$REPO/config" | xargs -0 -r sed -i "s|$HOME|__HOME__|g"

echo "Synced. Review with: git -C $REPO status --short"
