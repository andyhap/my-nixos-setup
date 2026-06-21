#!/usr/bin/env bash

CONF_FILE="$HOME/.cache/caelestia/colors-kitty.conf"

caelestia scheme get | awk '
  # Ini penangkalnya: Hapus semua ANSI escape codes dari kolom hex
  { gsub(/\x1b\[[0-9;]*m/, "", $2) }
  
  # Tangkap warna teks dan background utama
  $1 == "text:" { fg = $2 }
  $1 == "base:" { bg = $2 }
  
  # Tangkap semua warna term0 sampai term15 secara otomatis
  $1 ~ /^term[0-9]+:/ { 
      key = substr($1, 1, length($1)-1)
      term[key] = $2 
  }
  
  # Tangkap warna seleksi kursor
  $1 == "primary:" { sel_bg = $2 }
  $1 == "onPrimary:" { sel_fg = $2 }
  
  # Tulis ulang dengan format Kitty (.conf)
  END {
      print "foreground #" fg
      print "background #" bg
      for (i=0; i<=15; i++) {
          print "color" i " #" term["term" i]
      }
      print "selection_background #" sel_bg
      print "selection_foreground #" sel_fg
  }
' > "$CONF_FILE"

# Buka Kitty seperti biasa
exec kitty "$@"
