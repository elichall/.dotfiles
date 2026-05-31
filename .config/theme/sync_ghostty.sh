#!/usr/bin/env bash

PALETTE_FILE="$HOME/.config/theme/palette.conf"
WAYBAR_CSS="$HOME/.config/waybar/colors.css"

mkdir -p "$HOME/.config/theme" "$HOME/.config/waybar"

# Direct query of Ghostty's fully evaluated background configuration state map
G_CONFIG=$(ghostty +show-config)

get_hex_base() {
  local match
  match=$(echo "$G_CONFIG" | grep -E "^$1[[:space:]]*=" | head -n1 | cut -d'=' -f2 | tr -d '[:space:]')
  echo "${match//[\"\']/}"
}

get_palette_hex() {
  local index="$1"
  echo "$G_CONFIG" | grep -E "^palette[[:space:]]*=[[:space:]]*${index}=" | head -n1 | cut -d'#' -f2 | tr -d '[:space:]'
}

BG=$(get_hex_base "background" | tr -d '#')
FG=$(get_hex_base "foreground" | tr -d '#')
ACCENT=$(get_palette_hex "2")
MUTED=$(get_palette_hex "8")

BG=${BG:-"000000"}
FG=${FG:-"cdd6f4"}
ACCENT=${ACCENT:-"a6e3a1"}
MUTED=${MUTED:-"585b70"}

# Generate Hyprland colors file
cat <<EOF >"$PALETTE_FILE"
\$bg = rgb($BG)
\$fg = rgb($FG)
\$accent = rgb($ACCENT)
\$muted = rgb($MUTED)
\$bg_hex = $BG
\$fg_hex = $FG
\$accent_hex = $ACCENT
\$muted_hex = $MUTED
EOF

# Generate Waybar and wlogout colors file
cat <<EOF >"$WAYBAR_CSS"
/* Dynamic Theme Colors */
@define-color theme_bg #$BG;
@define-color theme_fg #$FG;
@define-color theme_accent #$ACCENT;
@define-color theme_muted #$MUTED;
EOF

# High-Performance System Component Reload Signals
killall -USR2 waybar
hyprctl reload
killall -SIGUSR2 ghostty
