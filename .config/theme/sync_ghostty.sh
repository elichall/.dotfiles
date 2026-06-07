#!/usr/bin/env bash

# System target paths
PALETTE_FILE="$HOME/.config/theme/palette.conf"
WAYBAR_CSS="$HOME/.config/waybar/colors.css"
TMUX_COLORS="$HOME/.config/tmux/colors.tmux"

# Ensure target directories exist before writing
mkdir -p "$HOME/.config/theme" "$HOME/.config/waybar" "$HOME/.config/tmux"

# 1. Query Ghostty's raw runtime configuration tree
G_CONFIG=$(ghostty +show-config)

get_hex_base() {
  local match
  match=$(echo "$G_CONFIG" | grep -E "^$1[[:space:]]*=" | head -n1 | cut -d'=' -f2 | tr -d '[:space:]#')
  echo "${match//[\"\']/}"
}

get_palette_hex() {
  local index="$1"
  echo "$G_CONFIG" | grep -E "^palette[[:space:]]*=[[:space:]]*${index}=" | head -n1 | cut -d'#' -f2 | tr -d '[:space:]'
}

BG=$(get_hex_base "background")
FG=$(get_hex_base "foreground")
ACCENT=$(get_palette_hex "2") # ANSI 2 (Green)
MUTED=$(get_palette_hex "8")  # ANSI 8 (Bright Black / Muted Gray)

BG=${BG:-"000000"}
FG=${FG:-"cdd6f4"}
ACCENT=${ACCENT:-"a6e3a1"}
MUTED=${MUTED:-"585b70"}

# [Previous Hyprland and Waybar file generation omitted for brevity but preserved intact]
# ... (Keep your existing cat updates for PALETTE_FILE and WAYBAR_CSS here) ...

# ==============================================================================
# GENERATE DYNAMIC COLOR-AGNOSTIC TMUX STYLING DEFINITIONS
# ==============================================================================
cat <<EOF >"$TMUX_COLORS"
# Automatically generated from active Ghostty profile
# 1. Status Bar Foundation Structure
set -g status-style "bg=#$BG,fg=#$FG"
set -g status-left-length 40
set -g status-left "#[fg=#$BG,bg=#$ACCENT,bold] 󰨖 #S #[bg=default,fg=default] "
set -g status-right "#[fg=#$MUTED,bg=default]󰇄 #H "

# 2. Inactive vs Active Window List Elements
set -g window-status-format "#[fg=#$MUTED,bg=default] #I:#W "
set -g window-status-current-format "#[fg=#$ACCENT,bg=#$MUTED,bold] #I:#W "
set -g window-status-separator ""

# 3. Structural Pane Dividing Lines
set -g pane-border-style "fg=#$MUTED"
set -g pane-active-border-style "fg=#$ACCENT"

# 4. Command Input and Message Bar Line Rules
set -g message-style "bg=#$MUTED,fg=#$ACCENT,bold"
EOF

# ==============================================================================
# ATOMIC GRAPHIC PIPELINE HOT-RELOADS
# ==============================================================================
killall -USR2 waybar
hyprctl reload
killall -SIGUSR2 ghostty

# Dynamic Tmux State Synchronization: Forces all background servers to reload configurations
if [ -n "$TMUX" ]; then
  tmux source-file "$HOME/.tmux.conf"
fi
