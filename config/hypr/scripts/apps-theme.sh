#!/usr/bin/env bash
T="$HOME/.config/themes"
name=${1:-$(cat "$T/.current")}
. "$T/$name.sh"

# ---- GTK 3 and 4 ----
for v in 3.0 4.0; do
  d="$HOME/.config/gtk-$v"
  mkdir -p "$d"
  [ -f "$d/gtk.css" ] && [ ! -f "$d/gtk.css.orig" ] && cp "$d/gtk.css" "$d/gtk.css.orig"
  cat > "$d/gtk.css" <<EOF
@define-color accent_color #$A1;
@define-color accent_bg_color #$A1;
@define-color accent_fg_color #$BG;
@define-color window_bg_color #$BG;
@define-color window_fg_color #$FG;
@define-color view_bg_color #$BG;
@define-color view_fg_color #$FG;
@define-color headerbar_bg_color #$BG2;
@define-color headerbar_fg_color #$FG;
@define-color sidebar_bg_color #$BG2;
@define-color sidebar_fg_color #$FG;
@define-color card_bg_color #$BG2;
@define-color card_fg_color #$FG;
@define-color popover_bg_color #$BG2;
@define-color popover_fg_color #$FG;
@define-color dialog_bg_color #$BG2;
@define-color dialog_fg_color #$FG;
@define-color error_color #$ERR;
@define-color warning_color #$A3;
@define-color success_color #$A4;
@define-color theme_bg_color #$BG;
@define-color theme_fg_color #$FG;
@define-color theme_base_color #$BG;
@define-color theme_text_color #$FG;
@define-color theme_selected_bg_color #$A1;
@define-color theme_selected_fg_color #$BG;
EOF
done
gsettings set org.gnome.desktop.interface color-scheme "prefer-$MODE" 2>/dev/null

# ---- Kvantum (Dolphin and other Qt apps), derived from KvFlat ----
src=/usr/share/Kvantum/KvFlat
if [ -f "$src/KvFlat.kvconfig" ]; then
  K="$HOME/.config/Kvantum/Neon$name"
  mkdir -p "$K"
  cp "$src/KvFlat.svg" "$K/Neon$name.svg"
  awk '/^\[/{skip=($0=="[GeneralColors]")} !skip' "$src/KvFlat.kvconfig" > "$K/Neon$name.kvconfig"
  cat >> "$K/Neon$name.kvconfig" <<EOF

[GeneralColors]
window.color=#$BG
base.color=#$BG
alt.base.color=#$BG2
button.color=#$BG2
light.color=#$BG2
mid.light.color=#$BG2
dark.color=#$BG
mid.color=#$BG2
highlight.color=#$A1
inactive.highlight.color=#$MUTED
text.color=#$FG
window.text.color=#$FG
button.text.color=#$FG
disabled.text.color=#$MUTED
tooltip.base.color=#$BG2
tooltip.text.color=#$FG
highlight.text.color=#$BG
link.color=#$A4
link.visited.color=#$A2
EOF
  printf '[General]\ntheme=Neon%s\n' "$name" > "$HOME/.config/Kvantum/kvantum.kvconfig"
fi

# ---- Vesktop (QuickCSS reloads live) ----
mkdir -p "$HOME/.config/vesktop/settings"
cat > "$HOME/.config/vesktop/settings/quickCss.css" <<EOF
:root, .theme-light, .theme-dark, .theme-darker, .theme-midnight {
  --background-primary: #$BG;
  --background-secondary: #$BG2;
  --background-secondary-alt: #$BG2;
  --background-tertiary: #$BG;
  --background-base-lowest: #$BG;
  --background-base-lower: #$BG;
  --background-base-low: #$BG2;
  --background-surface-high: #$BG2;
  --chat-background-default: #$BG;
  --channeltextarea-background: #$BG2;
  --text-normal: #$FG;
  --header-primary: #$FG;
  --header-secondary: #$MUTED;
  --text-muted: #$MUTED;
  --interactive-normal: #$MUTED;
  --interactive-hover: #$A1;
  --interactive-active: #$A1;
  --brand-500: #$A1;
  --brand-experiment: #$A1;
  --text-link: #$A4;
}
EOF

