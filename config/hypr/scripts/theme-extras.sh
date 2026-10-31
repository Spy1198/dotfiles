#!/usr/bin/env bash
# usage: theme-extras.sh THEMENAME   (recolors cava and satty from the palette)
T="$HOME/.config/themes"
[ -f "$T/$1.sh" ] || exit 1
. "$T/$1.sh"

# cava gradient
C="$HOME/.config/cava/config"
if [ -f "$C" ]; then
  sed -i -E "s|^(gradient_color_1 = ).*|\1\"#$A1\"|; s|^(gradient_color_2 = ).*|\1\"#$A4\"|; s|^(gradient_color_3 = ).*|\1\"#$A2\"|; s|^(gradient_color_4 = ).*|\1\"#$A2\"|" "$C"
  pkill -USR2 -x cava 2>/dev/null
fi

# satty annotation colors
S="$HOME/.config/satty"
mkdir -p "$S"
[ -f "$S/config.toml" ] && [ ! -f "$S/config.toml.bak" ] && cp "$S/config.toml" "$S/config.toml.bak"
cat > "$S/config.toml" <<EOF
[color-palette]
palette = ["#$A1", "#$A2", "#$A3", "#$ERR", "#$FG", "#$BG"]
EOF
