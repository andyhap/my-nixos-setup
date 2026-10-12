-- Input keyboard dan perangkat.

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
        force_no_accel = true,

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- Gesture tiga jari untuk berpindah workspace.

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- Sensitivitas perangkat tertentu.

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})
