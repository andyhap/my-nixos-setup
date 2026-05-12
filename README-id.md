🌍 *Read this in other languages: [English](README.md) | [Bahasa Indonesia](README-id.md)*

---

# ❄️ Andy Hikmal's NixOS Dotfiles

Repositori ini berisi konfigurasi sistem NixOS saya secara lengkap, dikelola menggunakan **Nix Flakes** dan **Home Manager**. Setup ini ditujukan untuk laptop hybrid Intel/NVIDIA dengan Hyprland sebagai window manager, dilengkapi integrasi Caelestia untuk dynamic theming berbasis wallpaper.

---

## ⚠️ Peringatan Sebelum Menggunakan

> **Konfigurasi ini bukan template generik.** Pahami hal-hal berikut sebelum menyalin atau mengadaptasi repo ini:

- **Spesifik hardware**: Konfigurasi NVIDIA Prime di `configuration.nix` menggunakan `intelBusId = "PCI:0:2:0"` dan `nvidiaBusId = "PCI:1:0:0"` yang sesuai dengan mesin saya. Nilai ini **hampir pasti berbeda** di mesin kamu — menggunakannya tanpa penyesuaian dapat menyebabkan sistem gagal booting atau layar tidak muncul.
- **Spesifik username**: Seluruh konfigurasi (path, user, grup, aliases) menggunakan username `andyh`. Ganti semua kemunculannya di seluruh file `.nix` sebelum menerapkan.
- **NixOS unstable**: Flake ini menggunakan channel `nixos-unstable`. Perilaku beberapa paket bisa berubah sewaktu-waktu.
- **Bukan untuk pemula**: Membutuhkan pemahaman dasar tentang NixOS, Nix Flakes, dan Home Manager.
- **Backup data terlebih dahulu** sebelum menjalankan `nixos-rebuild`.

---

## ✨ Fitur Utama

| Komponen | Detail |
|---|---|
| **Window Manager** | Hyprland (Wayland), sesi dikelola via UWSM |
| **Display Manager** | SDDM dengan tema `sddm-astronaut-theme` (varian pixel_sakura_static) |
| **Terminal** | Kitty dengan dynamic theming via `kitty-wrapper.sh` |
| **Shell** | Bash dengan aliases untuk manajemen NixOS |
| **Prompt** | Starship dengan preset Catppuccin |
| **Dynamic Theming** | Caelestia Shell & CLI — warna terminal sync otomatis dari wallpaper aktif |
| **GTK Theme** | Graphite-Dark |
| **Icon Theme** | Tela-circle-dark |
| **Cursor** | Bibata-Modern-Ice |
| **File Manager** | Thunar (dikelola di `configuration.nix`) |
| **Hardware** | NVIDIA Prime Offload mode + Intel iGPU, Bluetooth, PipeWire |
| **Virtualisasi** | VirtualBox + libvirtd (QEMU/KVM) + GNS3 |

---

## 📁 Struktur Repositori

```
.
├── flake.nix                    # Entry point flake — mendefinisikan semua input dan output sistem
├── flake.lock                   # Lock file versi dependensi
├── configuration.nix            # Konfigurasi sistem utama (boot, hardware, services, driver)
├── hardware-configuration.nix   # Hasil scan hardware — JANGAN disalin langsung
├── home.nix                     # Konfigurasi user via Home Manager (paket, dotfiles, aliases)
├── starship-catppuccin.toml     # Konfigurasi prompt Starship (tema Catppuccin)
└── config/
    └── hypr/
        ├── hyprland.conf        # Konfigurasi utama Hyprland
        └── scripts/
            └── kitty-wrapper.sh # Launcher Kitty dengan injeksi warna dinamis
```

---

## 🔌 Flake Inputs

Selain `nixpkgs` dan `home-manager`, flake ini menggunakan input berikut:

- **[Helium Browser](https://github.com/schembriaiden/helium-browser-nix-flake)** — browser alternatif yang dipasang via flake terpisah.
- **[caelestia-shell](https://github.com/caelestia-dots/shell)** & **[caelestia-cli](https://github.com/caelestia-dots/cli)** — tooling di balik dynamic theming berbasis wallpaper.

---

## 🚀 Instalasi

> Mengasumsikan kamu sudah memiliki instalasi NixOS bersih dengan koneksi internet.

### 1. Aktifkan Flakes

Pastikan fitur eksperimental sudah aktif di `/etc/nixos/configuration.nix`:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Lalu jalankan `sudo nixos-rebuild switch` sekali untuk menerapkan perubahan ini.

### 2. Kloning Repositori

```bash
git clone https://github.com/USERNAME_KAMU/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

### 3. Ganti Hardware Configuration

**Langkah ini wajib.** Salin hardware config dari mesin kamu sendiri:

```bash
cp /etc/nixos/hardware-configuration.nix ~/nixos-config/
```

Kemudian buka `configuration.nix` dan sesuaikan nilai `intelBusId` dan `nvidiaBusId` berdasarkan output `lspci`:

```bash
lspci | grep -E "VGA|3D"
```

Cara membaca Bus ID dari outputnya:
```
00:02.0 VGA compatible controller: Intel ...   → PCI:0:2:0
01:00.0 3D controller: NVIDIA ...              → PCI:1:0:0
```

### 4. Ganti Username

Cari dan ganti semua kemunculan `andyh` dengan username kamu di:
- `flake.nix` → `home-manager.users.andyh`
- `configuration.nix` → `users.users.andyh`, path di `shellAliases`
- `home.nix` → `home.username`, `home.homeDirectory`

### 5. Build dan Aktivasi

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#nixos
```

---

## 🎨 Cara Kerja Dynamic Theming (Caelestia + Kitty)

Pipeline theming ini berjalan otomatis setiap kali terminal dibuka:

1. **Caelestia** membaca wallpaper yang sedang aktif dan menghasilkan palet warna 16-warna dari gambar tersebut.
2. **`kitty-wrapper.sh`** dieksekusi sebagai pengganti perintah `kitty` langsung. Script ini memanggil `caelestia wallpaper -p` untuk mengambil palet warna dalam format JSON, lalu memparsanya dengan `jq` dan menulis hasilnya ke `~/.cache/caelestia/colors-kitty.conf`.
3. **Kitty** dibuka dengan warna yang baru saja ditulis melalui directive `include` di konfigurasi Kitty (`home.nix`).

> **Catatan:** Symlink antara `config/hypr/` di repo ini ke `~/.config/hypr/` dibuat secara otomatis oleh Home Manager melalui opsi `xdg.configFile` di `home.nix`.

---

## ⌨️ Bash Aliases

Didefinisikan di `home.nix` dan langsung tersedia setelah aktivasi:

| Alias | Perintah Penuh | Keterangan |
|---|---|---|
| `rebuild` | `sudo nixos-rebuild switch --flake ~/nixos-config#nixos` | Rebuild dan aktivasi sistem penuh |
| `rebuild-fast` | `sudo nixos-rebuild switch --fast ...` | Rebuild cepat (skip beberapa pengecekan) |
| `rebuild-build` | `sudo nixos-rebuild build ...` | Build saja, tanpa aktivasi |
| `rollback` | `sudo nixos-rebuild switch --rollback` | Kembali ke generasi sebelumnya |
| `gens` | `sudo nix-env --list-generations ...` | Tampilkan daftar generasi sistem |
| `update` | `nix flake update && rebuild` | Update semua flake input lalu rebuild |
| `nix-clean` | `sudo nix-collect-garbage -d && ...` | Hapus generasi lama dan optimasi store |
| `edit-nix` | `nano ~/nixos-config/configuration.nix` | Edit konfigurasi sistem |
| `edit-flake` | `nano ~/nixos-config/flake.nix` | Edit flake |
| `edit-home` | `nano ~/nixos-config/home.nix` | Edit konfigurasi Home Manager |
| `edit-hypr` | `nano ~/nixos-config/config/hypr/hyprland.conf` | Edit konfigurasi Hyprland |
| `nixfast` | `nix shell nixpkgs#` | Buka shell sementara dengan paket dari nixpkgs |

---

## 📝 Catatan Tambahan

- **`system.stateVersion` dan `home.stateVersion`** di-set ke `"25.11"`. Jangan ubah nilai ini kecuali kamu tahu artinya — ini adalah penanda versi NixOS saat pertama kali diinstall, bukan versi yang perlu diupdate terus.
- **`home.activation.removeBackups`**: Home Manager dikonfigurasi untuk otomatis menghapus file `*.backup` (dibuat saat ada konflik symlink) setelah proses aktivasi selesai.
- **NoiseTorch** berjalan sebagai systemd user service (`noisetorch-mic`) yang otomatis dimuat saat sesi grafis dimulai, dengan delay 5 detik untuk memastikan PipeWire sudah siap.
- File `hardware-configuration.nix` yang ada di repo ini adalah milik mesin saya. File ini **disertakan hanya sebagai referensi struktur** — jangan digunakan langsung.
