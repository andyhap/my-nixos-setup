#!/usr/bin/env bash

CONF_FILE="$HOME/.cache/caelestia/colors-kitty.conf"

# 1. Sedot JSON warna langsung dari wallpaper yang SEDANG AKTIF!
# 2. Parse menggunakan jq, ambil dari object ".colours", dan simpan ke .conf
caelestia wallpaper -p 2>/dev/null | jq -r '
  "foreground #\(.colours.text)",
  "background #\(.colours.base)",
  "color0 #\(.colours.term0)",
  "color1 #\(.colours.term1)",
  "color2 #\(.colours.term2)",
  "color3 #\(.colours.term3)",
  "color4 #\(.colours.term4)",
  "color5 #\(.colours.term5)",
  "color6 #\(.colours.term6)",
  "color7 #\(.colours.term7)",
  "color8 #\(.colours.term8)",
  "color9 #\(.colours.term9)",
  "color10 #\(.colours.term10)",
  "color11 #\(.colours.term11)",
  "color12 #\(.colours.term12)",
  "color13 #\(.colours.term13)",
  "color14 #\(.colours.term14)",
  "color15 #\(.colours.term15)",
  "selection_background #\(.colours.primary)",
  "selection_foreground #\(.colours.onPrimary)"
' > "$CONF_FILE"

# 3. Buka Kitty
exec kitty "$@"
