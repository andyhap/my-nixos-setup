
-- Keybinds: config/hypr/modules/keybinds.lua

local mainMod = "SUPER"

local programs = require("modules.programs")
local terminal = programs.terminal
local fileManager = programs.fileManager

-- Applications and window controls
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprctl dispatch exit"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Focus movement
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10 (0 selects workspace 10)
for i = 1, 10 do
    local key = tostring(i % 10)

    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = i })
    )

    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i })
    )
end

-- Special workspace
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(
    mainMod .. " + SHIFT + S",
    hl.dsp.window.move({ workspace = "special:magic" })
)

-- Cycle through workspaces with the mouse wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move and resize windows with mouse buttons
hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)
hl.bind(
    mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)

-- Audio volume and mute
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true }
)
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true }
)

-- Display brightness
hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
    { locked = true, repeating = true }
)

-- Media player controls
hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"),
    { locked = true }
)
hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)
hl.bind(
    "XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)
hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"),
    { locked = true }
)

-- Caelestia
hl.bind(
    mainMod .. " + D",
    hl.dsp.exec_cmd("caelestia shell drawers toggle launcher")
)
hl.bind(
    mainMod .. " + L",
    hl.dsp.global("caelestia:lock"),
    { locked = true }
)

-- Other applications
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("helium"))

-- Full screenshot: save and copy to clipboard
hl.bind(
    "Print",
    hl.dsp.exec_cmd(
        [[bash -c 'DIR=~/Pictures/Screenshots/Full; mkdir -p "$DIR"; FILE="$DIR/full-$(date +%Y%m%d_%H%M%S).png"; grim "$FILE" && wl-copy < "$FILE"']]
    )
)

-- Region screenshot: save and copy to clipboard
hl.bind(
    "SHIFT + Print",
    hl.dsp.exec_cmd(
        [[bash -c 'DIR=~/Pictures/Screenshots/Region; mkdir -p "$DIR"; FILE="$DIR/region-$(date +%Y%m%d_%H%M%S).png"; grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE"']]
    )
)

-- Select a region and open Swappy for annotation
hl.bind(
    "CTRL + Print",
    hl.dsp.exec_cmd([[bash -c 'grim -g "$(slurp)" - | swappy -f -']])
)
