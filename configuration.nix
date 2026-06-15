# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

let
  astronaut-theme = pkgs.stdenv.mkDerivation {
    name = "sddm-astronaut-theme";
    src = pkgs.fetchFromGitHub {
      owner = "Keyitdev";
      repo = "sddm-astronaut-theme";
      rev = "master";
      sha256 = "sha256-+94WVxOWfVhIEiVNWwnNBRmN+d1kbZCIF10Gjorea9M=";
    };

    installPhase = ''
       mkdir -p $out/share/sddm/themes/sddm-astronaut-theme
       cp -r ./* $out/share/sddm/themes/sddm-astronaut-theme/
 
       sed -i 's|ConfigFile=.*|ConfigFile=Themes/pixel_sakura_static.conf|' \
        $out/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
     '';
  };
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.initrd.includeDefaultModules = true;
  boot.initrd.kernelModules = [ 
    "i915"
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
    gfxmodeEfi = "1920x1080,auto";
    gfxpayloadEfi = "keep";  
    splashImage = null;
  }; 

 boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "nvidia-drm.modeset=1"  
    "nvidia-drm.fbdev=1"
    "i915.enable_psr=0"
    "i915.enable_guc=3" 
    "i915.force_probe=46a3"
    "vt.global_cursor_default=0"
    "fbcon=map:1"
    "video=efifb:off" 
    "drm.debug=0"
    "initcall_blacklist=simpledrm_platform_driver_init"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  boot.kernelModules = [ "vboxdrv" "vboxnetflt" "vboxnetadp" "tun" ];

  boot.supportedFilesystems = [ "ntfs" ];

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  boot.initrd.systemd.enable = true;

  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # Set your time zone.
  # time.timeZone = "Asia/Jakarta";
  time.timeZone = "Asia/Makassar";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andyh = {
    isNormalUser = true;
    description = "Andy Hikmal";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "vboxusers" "ubridge" "libvirtd" "render" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Hardware & System Tools
    brightnessctl
    evhz
    mesa-demos
    libnotify
    gpu-screen-recorder
    polkit_gnome    
    file-roller
    unrar
    p7zip  
    # SDDM
    astronaut-theme

    # Virtualization & Networking Server
    gns3-server
    dynamips
    qemu
  ];

  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
    inputs.codex-cli.overlays.default

    (final: prev: {
      gns3-server = prev.gns3-server.overrideAttrs (old: rec {
        version = "2.2.59";
        src = prev.fetchFromGitHub {
          owner = "GNS3";
          repo = "gns3-server";
          tag = "v${version}";
          hash = "sha256-xsiwD+o9M/ZwR8t+EA9mWxAlfSKLCvNr1U2qRcmSDzg=";
        };
      });

      gns3-gui = prev.gns3-gui.overridePythonAttrs (old: rec {
        version = "2.2.59";
        src = prev.fetchFromGitHub {
          owner = "GNS3";
          repo = "gns3-gui";
          tag = "v${version}";
          hash = "sha256-eYtuGVRfgUFBLxGT0xfiMhbjoMzc6F/VHjI9VN3ADAs=";
        };
        patches = [];
        dependencies = old.dependencies ++ [ prev.python3Packages.qdarkstyle ];
      });
    })
  ];

  # enable realtime kit
  security.rtkit.enable = true;

  environment.sessionVariables = {
      # QSG_RHI_BACKEND = "opengl";
      QSG_RHI_BACKEND = "basic";
      QSG_RENDER_LOOP = "threaded";

      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland";

      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "24";

      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";

      LIBVA_DRIVER_NAME = "iHD";
      NIXOS_OZONE_WL = "1";

      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "1";

      MOZ_ENABLE_WAYLAND = "1";
      MOZ_WEBRENDER = "1";

      __GL_SHADER_DISK_CACHE = "1";
      __GL_SHADER_DISK_CACHE_PATH = "/home/andyh/.cache/nv_shaders";
      __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
  };

  fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      material-symbols
      noto-fonts
      noto-fonts-cjk-sans
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;
 
  programs.noisetorch.enable = true;

  programs.xfconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  programs.nix-ld.enable = true;

  xdg.portal = {
  enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];

    config.common.default = ["hyprland" "gtk"];
  };
  
  hardware.bluetooth.enable = true;
  
  # power management 
  powerManagement.cpuFreqGovernor = "schedutil";

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  virtualisation.libvirtd.enable = true;

  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw+ep";
    owner = "root";
    group = "ubridge";   
    permissions = "0750"; 
  };

  users.groups.ubridge = {};

   security.wrappers.gpu-screen-recorder = {
     owner = "root";
     group = "root";
     capabilities = "cap_sys_admin+ep";
     source = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder";
  };

  security.wrappers.gsr-kms-server = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
  };

  # List services that you want to enable:
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    
    extraPackages = with pkgs; [
      qt6.qtbase
      qt6Packages.qtdeclarative
      qt6Packages.qtsvg
      qt6Packages.qtmultimedia
    ];
  };

  # Power Management Service
  services.thermald.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # auto login
  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "andyh";

  # audio
  services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
  };

  # Thunar service
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;
  security.polkit.enable = true;  
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
           action.id == "org.freedesktop.udisks2.filesystem-mount") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # NVDIA Driver
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # prime hybrid
      prime = {
        offload.enable = true;        
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
  };

  hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        nvidia-vaapi-driver
        libva-utils
      ];
  };


  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  
    trusted-users = [ "root" "andyh" ];
    substituters = [ 
      "https://claude-code.cachix.org" 
      "https://codex-cli.cachix.org" 
    ];

    trusted-public-keys = [ 
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" 
      "codex-cli.cachix.org-1:9u3p9Nl9RmW1W2t7/rEv9TDuEAsYkC1w7u6M8sRkK8Y="
      "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
    ];
  };

  # zram
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 10;
  };

  # swap memory
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 8 * 1024; # 8GB dalam satuan Megabytes
    priority = 5;
  } ];

  system.stateVersion = "25.11"; # Did you read the comment?
}
