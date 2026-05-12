{ config, pkgs, inputs, lib, ... }:

{
  home.username = "andyh";
  home.homeDirectory = "/home/andyh";
  home.stateVersion = "25.11"; # Sesuaikan dengan versi NixOS kamu

  # Paket aplikasi user (Bisa diatur temanya secara dinamis)
  home.packages = with pkgs; [
    # Dev & Terminal
    vim
    wget
    git
    fastfetch
    jq
    pkgs.vscode
    postman
    pkgs.nodejs_22
    
    # Internet & Chat
    firefox
    discord
    telegram-desktop
    inputs.helium.packages.${pkgs.system}.default    

    # Media & Graphics
    obs-studio
    pavucontrol
    imv
    mpv
    ffmpeg
    swappy
    grim
    slurp
    wl-clipboard
    pulseaudio
    
    # Office & Tools
    onlyoffice-desktopeditors
    remmina
    freerdp
    spice
    gns3-gui

    # File Manager & Theming
    bibata-cursors
    qt6Packages.qt6ct
    # thunar
    # thunar-archive-plugin
    # thunar-volman
    graphite-gtk-theme
    tela-circle-icon-theme
    pkgs.tumbler
    pkgs.ffmpegthumbnailer
    pkgs.libgsf
    pkgs.evince
    pkgs.gvfs
  ];

  # Konfigurasi Kitty
  programs.kitty = {
    enable = true;
    
    # Mengaktifkan IPC dan Remote Control
    settings = {
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      dynamic_background_opacity = "yes";
    };

    extraConfig = ''
      # 1. Load warna dinamis dari Caelestia
      include ~/.cache/caelestia/colors-kitty.conf
      
      # 2. Settingan untuk kitty
      background_opacity 0.6
      background_blur 15
      confirm_os_window_close 0

      # 3. Font & UI
      font_family JetBrainsMono Nerd Font
      font_size 11.0
      window_padding_width 4
    '';
  };

  # Pengaturan kursor agar konsisten
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # Graphite theme
  gtk = {
    enable = true;
    
    theme = {
      name = "Graphite-Dark";
      package = pkgs.graphite-gtk-theme.override {
        themeVariants = [ "default" ];
        colorVariants = [ "dark" ];
      };
    };

    iconTheme = {
      name = "Tela-circle-dark";
      package = pkgs.tela-circle-icon-theme;
    };

    gtk4.theme = config.gtk.theme;
  };

  # starship
  programs.starship = {
    enable = true;
    
    # Otomatis integrasi ke bash
    enableBashIntegration = true; 

    # Membaca file TOML eksternal secara declarative
    settings = builtins.fromTOML (builtins.readFile ./starship-catppuccin.toml);
  };

  # Membiarkan Home Manager mengelola dirinya sendiri
  programs.home-manager.enable = true;

  # Otomatis hapus semua file berakhiran .backup setelah aktivasi selesai
  home.activation.removeBackups = lib.hm.dag.entryAfter ["writeBoundary"] ''
    find ${config.home.homeDirectory} -name "*.backup" -type f -delete
  '';
  
  # Symlink Hyprland & Script Kitty
  xdg.configFile."hypr" = {
    source = ./config/hypr;
    recursive = true;
  };
  xdg.configFile."hypr/scripts/kitty-wrapper.sh".executable = true;

  # Konfigurasi Environment khusus Hyprland lewat UWSM
  xdg.configFile."uwsm/env-hyprland".text = ''
    export AQ_DRM_DEVICES="/dev/dri/card1:/dev/dri/card0"
    export AQ_FORCE_LINEAR_BLIT="1"
    export AQ_MGPU_NO_EXPLICIT="0"
  '';

  # konfigurasi bash
  programs.bash = {
    enable = true;
    
    # Home Manager otomatis akan membuatkan alias ini di .bashrc kamu
    shellAliases = {
      # --- NixOS Rebuild Aliases ---
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
      rebuild-fast = "sudo nixos-rebuild switch --fast --flake ~/nixos-config#nixos";
      rebuild-build = "sudo nixos-rebuild build --flake ~/nixos-config#nixos";
      rollback = "sudo nixos-rebuild switch --rollback";
      gens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      update = "nix flake update ~/nixos-config && rebuild";
      nix-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d && sudo nix-store --optimize";

      # --- Edit Configs ---
      # Tidak perlu sudo lagi karena folder ~/nixos-config milik user andyh
      edit-nix = "nano ~/nixos-config/configuration.nix";
      edit-flake = "nano ~/nixos-config/flake.nix";
      edit-home = "nano ~/nixos-config/home.nix";
      edit-hypr = "nano ~/nixos-config/config/hypr/hyprland.conf";

      # --- Utils ---
      nixfast = "nix shell nixpkgs#";
    };
  };

  # konfigurasi khusus untuk pipewire-pulse
  xdg.configFile."systemd/user/pipewire-pulse.service.d/ladspa-fix.conf".text = ''
    [Service]
    Environment="LADSPA_PATH=/tmp"
  '';

  # konfigurasi dan auto start noisetorch
  xdg.desktopEntries.noisetorch = {
    name = "NoiseTorch";
    genericName = "Microphone Noise Suppression";
    exec = "systemd-run --user --scope /run/wrappers/bin/noisetorch";
    icon = "noisetorch";
    terminal = false;
    categories = [ "AudioVideo" "Audio" ];
  };

  systemd.user.services.noisetorch-mic = {
    Unit = {
      Description = "NoiseTorch Auto-Load for Internal Mic";
      After = [ "pipewire.service" "pipewire-pulse.service" "graphical-session.target" ];
      Requires = [ "pipewire-pulse.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeShellScript "run-noisetorch" ''
        sleep 5
        
        MIC_NAME=$(${pkgs.pulseaudio}/bin/pactl get-default-source)

        if [ -n "$MIC_NAME" ] && [ "$MIC_NAME" != "noisetorch" ]; then
          # Bersihkan sisa noisetorch yang mungkin nyangkut
          /run/wrappers/bin/noisetorch -u || true
          sleep 1
          
          /run/wrappers/bin/noisetorch -i "$MIC_NAME"
          sleep 2
          
          # set default mic ke noise torch
          # ${pkgs.pulseaudio}/bin/pactl set-default-source noisetorch
        fi
      ''}";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
