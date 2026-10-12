
#!/usr/bin/env bash
set -euo pipefail

PRIMARY=$(caelestia wallpaper -p | jq -r '.colours.primary')
TERTIARY=$(caelestia wallpaper -p | jq -r '.colours.tertiary')
INACTIVE=$(caelestia wallpaper -p | jq -r '.colours.surfaceVariant')

STATE="$HOME/.cache/caelestia/.last-border-colour"
CURRENT="${PRIMARY}-${TERTIARY}-${INACTIVE}"

mkdir -p "$(dirname "$STATE")"

if [[ "${1:-}" != "--force" ]] &&
   [[ -f "$STATE" ]] &&
   [[ "$(cat "$STATE")" == "$CURRENT" ]] &&
   [[ "$(hyprctl getoption general:col.active_border)" == *"ee${PRIMARY}"* ]]; then
    exit 0
fi

hyprctl eval "hl.config({ general = { [\"col.active_border\"] = \"rgba(${PRIMARY}ee)\", [\"col.inactive_border\"] = \"rgba(${INACTIVE}aa)\" } })"

printf '%s\n' "$CURRENT" > "$STATE"

kitty @ load-config >/dev/null 2>&1 || true
