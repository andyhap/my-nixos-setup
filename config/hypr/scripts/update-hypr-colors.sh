#!/usr/bin/env bash

PRIMARY=$(caelestia wallpaper -p | jq -r '.colours.primary')
TERTIARY=$(caelestia wallpaper -p | jq -r '.colours.tertiary')
INACTIVE=$(caelestia wallpaper -p | jq -r '.colours.surfaceVariant')

STATE="$HOME/.cache/caelestia/.last-border-colour"

CURRENT="${PRIMARY}-${TERTIARY}-${INACTIVE}"

if [[ -f "$STATE" ]] && [[ "$(cat "$STATE")" == "$CURRENT" ]]; then
    exit 0
fi

echo "$CURRENT" > "$STATE"

cat > "$HOME/.cache/caelestia/colors-hyprland.conf" << EOF
general {
    col.active_border = rgba(${PRIMARY}ee) rgba(${TERTIARY}ee) 45deg
    col.inactive_border = rgba(${INACTIVE}aa)
}
EOF

hyprctl reload

kitty @ load-config >/dev/null 2>&1 || true

