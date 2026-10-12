
-- Autostart: config/hypr/modules/autostart.lua

hl.on("hyprland.start", function()
    -- Polkit authentication agent
    hl.exec_cmd(
        "/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1"
    )

    -- Atur volume source Built-in Audio setelah PipeWire siap.
    -- Logika pencarian source mengikuti hyprland.conf lama.
    hl.exec_cmd([[sleep 2 && bash -c 'wpctl set-volume $(wpctl status | sed -n "/Sources:/,/Filters:/p" | grep "Built-in Audio" | grep -o "^[^0-9]*[0-9]\+\." | grep -o "[0-9]\+") 0.28']])
    hl.exec_cmd("~/.local/bin/update-hypr-colors.sh --force")
end)
