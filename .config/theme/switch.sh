#!/usr/bin/env bash

# Config Target Anchors
THEME_DIR="$HOME/.config/theme"
THEME_JSON="$THEME_DIR/active.json"
GHOSTTY_TARGET="$HOME/.config/ghostty/active_theme"
EXTRACTOR_SCRIPT="$THEME_DIR/sync_ghostty.sh"

# --- POSITION PARAMETER LOOKUP ---
# Check if a specific profile argument was passed to the script
if [ -n "$1" ]; then
  TARGET_PROFILE="$THEME_DIR/profiles/$1.json"

  if [ -f "$TARGET_PROFILE" ]; then
    echo "Switching active configuration to profile: $1"
    cp "$TARGET_PROFILE" "$THEME_JSON"
  else
    echo "Error: Profile '$1' not found in $THEME_DIR/profiles/"
    echo "Available choices:"
    ls -1 "$THEME_DIR/profiles/" | sed 's/\.json//'
    exit 1
  fi
fi

# Ensure an active profile target exists to process
if [ ! -f "$THEME_JSON" ]; then
  echo "Error: Configuration asset active.json is missing."
  exit 1
fi

# 1. Parse JSON manifest metadata fields cleanly using jq
G_THEME=$(jq -r '.ghostty_theme' "$THEME_JSON")
WALLPAPER=$(jq -r '.wallpaper' "$THEME_JSON")

# 2. Update Ghostty's external layout profile variable
cat <<EOF >"$GHOSTTY_TARGET"
# Generated via theme engine automation
theme = $G_THEME
EOF

# 3. Synchronize your screen canvas profile backdrop
if command -v waypaper &>/dev/null; then
  waypaper --wallpaper "$WALLPAPER"
elif command -v swww &>/dev/null; then
  swww img "$WALLPAPER" --transition-type simple --outputs all
fi

# 4. SUB-SCRIPT CASCADE: Execute the color variable compiler matrix
if [ -x "$EXTRACTOR_SCRIPT" ]; then
  "$EXTRACTOR_SCRIPT"
else
  echo "Warning: Color variable pipeline handler script could not be executed."
fi
