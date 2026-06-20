#!/usr/bin/env bash

# System target paths
HYPR_PALETTE="$HOME/.config/hypr/palette.lua"
TMUX_COLORS="$HOME/.config/tmux/colors.tmux"
NVIM_PALETTE="$HOME/.config/nvim/lua/lean/core/palette.lua"
WAYBAR_CSS="$HOME/.config/waybar/colors.css"

# Ensure all structural target directories exist before writing assets
mkdir -p "$HOME/.config/theme" "$HOME/.config/waybar" "$HOME/.config/tmux" \
         "$HOME/.config/nvim/lua/lean/core"

# 1. Query Ghostty's raw runtime configuration tree
G_CONFIG=$(ghostty +show-config)

get_hex_base() {
    local match
    match=$(echo "$G_CONFIG" | grep -E "^$1[[:space:]]*=" | head -n1 | cut -d'=' -f2 | tr -d '[:space:]#')
    echo "${match//[\"\']}"
}

get_palette_hex() {
    local index="$1"
    echo "$G_CONFIG" | grep -E "^palette[[:space:]]*=[[:space:]]*${index}=" | head -n1 | cut -d'#' -f2 | tr -d '[:space:]'
}

# 2. Extract base properties cleanly using structured filtering rules
BG=$(get_hex_base "background")
FG=$(get_hex_base "foreground")

# Isolate the exact 16-color ANSI hex codes from Ghostty's engine memory
C0_BLACK=$(get_palette_hex "0")
C1_RED=$(get_palette_hex "1")
C2_GREEN=$(get_palette_hex "2")
C3_YELLOW=$(get_palette_hex "3")
C4_BLUE=$(get_palette_hex "4")
C5_MAGENTA=$(get_palette_hex "5")
C6_CYAN=$(get_palette_hex "6")
C7_WHITE=$(get_palette_hex "7")
C8_GRAY=$(get_palette_hex "8")

# Strict fallback verification overrides to handle potential missing keys
BG=${BG:-"000000"}
FG=${FG:-"cdd6f4"}
C0_BLACK=${C0_BLACK:-"1e1e2e"}
C1_RED=${C1_RED:-"f38ba8"}
C2_GREEN=${C2_GREEN:-"a6e3a1"}
C3_YELLOW=${C3_YELLOW:-"f9e2af"}
C4_BLUE=${C4_BLUE:-"89b4fa"}
C5_MAGENTA=${C5_MAGENTA:-"cba6f7"}
C6_CYAN=${C6_CYAN:-"89dceb"}
C7_WHITE=${C7_WHITE:-"cdd6f4"}
C8_GRAY=${C8_GRAY:-"585b70"}

cat <<EOF > "$HYPR_PALETTE"
local M = {}

M.bg = "rgb($BG)"
M.fg = "rgb($FG)"
M.accent = "rgb($C2_GREEN)"
M.muted = "rgb($C8_GRAY)"
M.bg_hex = "0x$BG"
M.fg_hex = "0x$FG"
M.accent_hex = "0x$C2_GREEN"
M.muted_hex = "0x$C8_GRAY"

return M
EOF

cat <<EOF > "$WAYBAR_CSS"
/* Dynamic Theme Colors */
@define-color theme_bg #$BG;
@define-color theme_fg #$FG;
@define-color theme_accent #$C2_GREEN;
@define-color theme_muted #$C8_GRAY;
EOF

cat <<EOF > "$TMUX_COLORS"
set -g status-style "bg=#$BG,fg=#$FG"
set -g status-left "#[fg=#$BG,bg=#$C2_GREEN,bold] 󰨖 #S #[bg=default,fg=default] "
set -g status-right "#[fg=#$C8_GRAY,bg=default]󰇄 #H "
set -g window-status-format "#[fg=#$C8_GRAY,bg=default] #I:#W "
set -g window-status-current-format "#[fg=#$C2_GREEN,bg=#$C8_GRAY,bold] #I:#W "
set -g window-status-separator ""
set -g pane-border-style "fg=#$C8_GRAY"
set -g pane-active-border-style "fg=#$C2_GREEN"
set -g message-style "bg=#$C8_GRAY,fg=#$C2_GREEN,bold"
EOF

# ==============================================================================
# GENERATE DYNAMIC NEOVIM LUA PALETTE
# ==============================================================================
cat <<EOF > "$NVIM_PALETTE"
-- lua/lean/core/palette.lua
-- This file is safely updated by your global engine, or serves as a static fallback.
return {
  bg       = "#$BG",
  fg       = "#$FG",
  black    = "#$C0_BLACK",
  red      = "#$C1_RED",
  green    = "#$C2_GREEN",
  yellow   = "#$C3_YELLOW",
  blue     = "#$C4_BLUE",
  magenta  = "#$C5_MAGENTA",
  cyan     = "#$C6_CYAN",
  white    = "#$C7_WHITE",
  gray     = "#$C8_GRAY",
}
EOF

# ==============================================================================
# ATOMIC RELOAD COMMANDS (Signals fixed to strictly uppercase definitions)
# ==============================================================================
killall -USR2 waybar
hyprctl reload
killall -SIGUSR2 ghostty

# Bypasses key simulation; forces atomic execution via background RPC channels
find "${XDG_RUNTIME_DIR:-/tmp}" -type s 2>/dev/null | grep "nvim" | while read -r server; do
    nvim --server "$server" --remote-expr "execute('lua package.loaded[\"lean.core.palette\"] = nil; vim.cmd(\"colorscheme lean_sync\")')" >/dev/null 2>&1 &
done

if [ -n "$TMUX" ]; then
    tmux source-file "$HOME/.tmux.conf"
fi
