#!/usr/bin/env bash
T="$HOME/.config/themes"
. "$T/$(cat "$T/.current").sh"
rgb() { printf '%d, %d, %d' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
C=$(rgb "$BG")

cat > "$HOME/.config/waybar/style.css" <<EOF
* {
  font-family: "JetBrainsMono Nerd Font";
  font-size: 13px;
  border: none;
  border-radius: 0;
  min-height: 0;
}

window#waybar {
  background: transparent;
  color: #$FG;
}

/* every module becomes its own floating island; gaps stay transparent */
.modules-left > widget > *,
.modules-center > widget > *,
.modules-right > widget > * {
  background: rgba($C, 0.88);
  color: #$A1;
  border: 1px solid #$A1;
  border-radius: 14px;
  padding: 4px 14px;
  margin: 0 4px;
}

#workspaces { padding: 2px 6px; }
#workspaces button {
  padding: 0 8px;
  margin: 0 2px;
  color: #$MUTED;
  background: transparent;
  border-radius: 10px;
}
#workspaces button.active { color: #$BG; background: #$A1; }
#workspaces button.urgent { color: #$BG; background: #$ERR; }
#workspaces button:hover { background: #$BG2; color: #$A2; }

#clock { color: #$A2; border-color: #$A2; }
#battery { color: #$A3; border-color: #$A3; }
#battery.charging { color: #$A4; border-color: #$A4; }
#battery.warning { color: #$A3; }
#battery.critical { color: #$ERR; border-color: #$ERR; }
#network.disconnected { color: #$ERR; border-color: #$ERR; }
#tray { padding: 4px 10px; }

tooltip {
  background: #$BG;
  border: 1px solid #$A1;
  border-radius: 10px;
}
tooltip label { color: #$FG; }
EOF
