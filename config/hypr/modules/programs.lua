
-- Program utama yang digunakan oleh konfigurasi Hyprland.

local programs = {
    terminal = os.getenv("HOME")
        .. "/.config/hypr/scripts/kitty-wrapper.sh",

    fileManager = "thunar",
}

return programs
