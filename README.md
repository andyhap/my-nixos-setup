🌍 *Read this in other languages: [English](README.md) | [Bahasa Indonesia](README-id.md)*

---

# ❄️ Andy Hikmal's NixOS Dotfiles

A complete NixOS system configuration managed with **Nix Flakes** and **Home Manager**. Built for a hybrid Intel/NVIDIA laptop running Hyprland as the window manager, with full Caelestia integration for wallpaper-driven dynamic theming.

---

## ⚠️ Read Before Using

> **This is not a generic template.** Understand the following before copying or adapting this repo:

- **Hardware-specific**: The NVIDIA Prime config in `configuration.nix` uses `intelBusId = "PCI:0:2:0"` and `nvidiaBusId = "PCI:1:0:0"` — values specific to my machine. These **will almost certainly be different** on yours. Using them without adjustment may cause boot failure or a black screen.
- **Username-specific**: Everything (paths, users, groups, aliases) is hardcoded to the username `andyh`. Replace all occurrences across all `.nix` files before applying.
- **NixOS unstable**: This flake tracks `nixos-unstable`. Package behavior may change at any time.
- **Back up your data** before running `nixos-rebuild`.

---

## ✨ Features

| Component | Details |
|---|---|
| **Window Manager** | Hyprland (Wayland), session managed via UWSM |
| **Display Manager** | SDDM with `sddm-astronaut-theme` (pixel_sakura_static variant) |
| **Terminal** | Kitty with dynamic theming via `kitty-wrapper.sh` |
| **Shell** | Bash with aliases for NixOS management |
| **Prompt** | Starship with Catppuccin preset |
| **Dynamic Theming** | Caelestia Shell & CLI — terminal colors auto-sync from active wallpaper |
| **GTK Theme** | Graphite-Dark |
| **Icon Theme** | Tela-circle-dark |
| **Cursor** | Bibata-Modern-Ice |
| **File Manager** | Thunar (managed in `configuration.nix`) |
| **Hardware** | NVIDIA Prime Offload mode + Intel iGPU, Bluetooth, PipeWire |
| **Virtualization** | VirtualBox + libvirtd (QEMU/KVM) + GNS3 |

---

## 📁 Repository Structure

```
.
├── flake.nix                    # Flake entry point — defines all inputs and system outputs
├── flake.lock                   # Pinned dependency versions
├── configuration.nix            # Main system config (boot, hardware, services, drivers)
├── hardware-configuration.nix   # Hardware scan result — DO NOT copy directly
├── home.nix                     # User config via Home Manager (packages, dotfiles, aliases)
├── starship-catppuccin.toml     # Starship prompt config (Catppuccin theme)
└── config/
    └── hypr/
        ├── hyprland.conf        # Main Hyprland configuration
        └── scripts/
            └── kitty-wrapper.sh # Kitty launcher with dynamic color injection
```

---

## 🔌 Flake Inputs

Beyond `nixpkgs` and `home-manager`, this flake pulls in:

- **[Helium Browser](https://github.com/schembriaiden/helium-browser-nix-flake)** — an alternative browser installed via its own flake.
- **[caelestia-shell](https://github.com/caelestia-dots/shell)** & **[caelestia-cli](https://github.com/caelestia-dots/cli)** — the tooling behind wallpaper-based dynamic theming.

---

## 🚀 Installation

> Assumes a clean NixOS installation with internet access.

### 1. Enable Flakes

Make sure experimental features are enabled in `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Then run `sudo nixos-rebuild switch` once to apply.

### 2. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

### 3. Replace the Hardware Configuration

**This step is mandatory.** Copy the hardware config from your own machine:

```bash
cp /etc/nixos/hardware-configuration.nix ~/nixos-config/
```

Then open `configuration.nix` and update the `intelBusId` and `nvidiaBusId` values based on your `lspci` output:

```bash
lspci | grep -E "VGA|3D"
```

How to read the Bus ID from the output:
```
00:02.0 VGA compatible controller: Intel ...   → PCI:0:2:0
01:00.0 3D controller: NVIDIA ...              → PCI:1:0:0
```

### 4. Replace the Username

Find and replace all instances of `andyh` with your username in:
- `flake.nix` → `home-manager.users.andyh`
- `configuration.nix` → `users.users.andyh`, paths in `shellAliases`
- `home.nix` → `home.username`, `home.homeDirectory`

### 5. Build and Activate

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#nixos
```

---

## 🎨 How Dynamic Theming Works (Caelestia + Kitty)

The theming pipeline runs automatically every time a terminal is opened:

1. **Caelestia** reads the currently active wallpaper and generates a 16-color palette from it.
2. **`kitty-wrapper.sh`** runs instead of calling `kitty` directly. It calls `caelestia wallpaper -p` to fetch the color palette as JSON, parses it with `jq`, and writes the result to `~/.cache/caelestia/colors-kitty.conf`.
3. **Kitty** opens with those freshly written colors via an `include` directive in its config (`home.nix`).

> **Note:** The symlink between `config/hypr/` in this repo and `~/.config/hypr/` is created automatically by Home Manager via the `xdg.configFile` option in `home.nix`.

---

## ⌨️ Bash Aliases

Defined in `home.nix`, available immediately after activation:

| Alias | Full Command | Description |
|---|---|---|
| `rebuild` | `sudo nixos-rebuild switch --flake ~/nixos-config#nixos` | Full system rebuild and activation |
| `rebuild-fast` | `sudo nixos-rebuild switch --fast ...` | Faster rebuild (skips some checks) |
| `rebuild-build` | `sudo nixos-rebuild build ...` | Build only, no activation |
| `rollback` | `sudo nixos-rebuild switch --rollback` | Roll back to the previous generation |
| `gens` | `sudo nix-env --list-generations ...` | List all system generations |
| `update` | `nix flake update && rebuild` | Update all flake inputs then rebuild |
| `nix-clean` | `sudo nix-collect-garbage -d && ...` | Delete old generations and optimize store |
| `edit-nix` | `nano ~/nixos-config/configuration.nix` | Edit system config |
| `edit-flake` | `nano ~/nixos-config/flake.nix` | Edit flake |
| `edit-home` | `nano ~/nixos-config/home.nix` | Edit Home Manager config |
| `edit-hypr` | `nano ~/nixos-config/config/hypr/hyprland.conf` | Edit Hyprland config |
| `nixfast` | `nix shell nixpkgs#` | Spawn a temporary shell with a nixpkgs package |

---

## 📝 Additional Notes

- **`system.stateVersion` and `home.stateVersion`** are set to `"25.11"`. Do not change these unless you know exactly what they mean — they mark the NixOS version at first install, not a version to keep updating.
- **`home.activation.removeBackups`**: Home Manager is configured to automatically delete `*.backup` files (created during symlink conflicts) once activation completes.
- **NoiseTorch** runs as a systemd user service (`noisetorch-mic`) that auto-loads at the start of a graphical session, with a 5-second delay to ensure PipeWire is ready.
- The `hardware-configuration.nix` in this repo belongs to my machine. It is **included for structural reference only** — do not use it directly.
