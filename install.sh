#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY=0; DO_PKGS=0; DO_CONF=0; DO_MSI=0
INSTALLED=()

log()   { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
run()   { if [ "$DRY" = 1 ]; then echo "[dry-run] $*"; else "$@"; fi; }
list()  { grep -v -e '^\s*#' -e '^\s*$' "$1"; }
usage() {
  echo "Usage: ./install.sh [--packages] [--configs] [--all] [--msi-bravo15] [--dry-run]"
  echo "  --all           packages + configs"
  echo "  --msi-bravo15   USB controller fixes for the MSI Bravo 15 (asks first)"
}

install_packages() {
  command -v pacman >/dev/null || { echo "This installer needs an Arch-based system (pacman)."; exit 1; }
  local native aur helper
  mapfile -t native < <(list "$REPO/packages/pacman.txt")
  mapfile -t aur < <(list "$REPO/packages/aur.txt")

  log "Installing ${#native[@]} packages from the repos"
  run sudo pacman -S --needed "${native[@]}"

  if command -v yay >/dev/null; then helper=yay
  elif command -v paru >/dev/null; then helper=paru
  else log "No AUR helper (yay/paru) found, skipping: ${aur[*]}"; return; fi

  log "Installing ${#aur[@]} packages with $helper"
  run "$helper" -S --needed "${aur[@]}"
}

install_configs() {
  log "Installing configs (existing ones are backed up to $BACKUP)"
  local src name dest
  for src in "$REPO"/config/*/; do
    name="$(basename "$src")"
    dest="$CONF/$name"
    if [ -e "$dest" ]; then
      log "Backing up $dest"
      run mkdir -p "$BACKUP"
      run cp -a "$dest" "$BACKUP/$name"
    fi
    run mkdir -p "$dest"
    run cp -a "$src." "$dest/"
    INSTALLED+=("$dest")
  done

  if [ "$DRY" = 0 ]; then
    log "Rendering home paths"
    grep -rIl --null '__HOME__' "${INSTALLED[@]}" 2>/dev/null \
      | xargs -0 -r sed -i "s|__HOME__|$HOME|g"
    chmod +x "$CONF"/hypr/scripts/* 2>/dev/null || true
  fi
  log "Edit the monitor names in $CONF/hypr/hyprland.conf if yours differ (eDP-1, HDMI-A-1)."
}

install_msi() {
  local d="$REPO/system/msi-bravo15" tmp ans
  read -r -p "Install MSI Bravo 15 USB fixes (PCI address 0000:07:00.4)? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || { log "Skipped hardware fixes"; return; }

  run sudo install -Dm644 "$d/etc/tmpfiles.d/xhci-power.conf" /etc/tmpfiles.d/xhci-power.conf
  run sudo install -Dm755 "$d/usr/local/bin/usb-reset" /usr/local/bin/usb-reset

  tmp="$(mktemp)"
  sed "s|__USER__|$USER|g" "$d/etc/sudoers.d/usb-reset" > "$tmp"
  if run sudo visudo -cf "$tmp"; then
    run sudo install -Dm440 "$tmp" /etc/sudoers.d/usb-reset
  else
    log "sudoers rule failed validation, not installed"
  fi
  rm -f "$tmp"
  log "Also add usbcore.autosuspend=-1 to GRUB_CMDLINE_LINUX_DEFAULT yourself, then run update-grub."
}

for arg in "$@"; do
  case "$arg" in
    --packages)     DO_PKGS=1 ;;
    --configs)      DO_CONF=1 ;;
    --all)          DO_PKGS=1; DO_CONF=1 ;;
    --msi-bravo15)  DO_MSI=1 ;;
    --dry-run)      DRY=1 ;;
    -h|--help)      usage; exit 0 ;;
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done
[ "$DO_PKGS$DO_CONF$DO_MSI" = "000" ] && { usage; exit 1; }

[ "$DO_PKGS" = 1 ] && install_packages
[ "$DO_CONF" = 1 ] && install_configs
[ "$DO_MSI" = 1 ] && install_msi
exit 0
