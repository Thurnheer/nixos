# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot = {
    initrd = {
    # List of modules that are always loaded by the initrd.
      kernelModules = [
        "i915"
        #"nvidia"
        #"nvidia_modeset"
        #"nvidia_drm"
      ];
    };
  };

  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidiafb"
  ];

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    #"i915.enable_dp_mst=0"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  #environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.nvidia.acceptLicense = true;
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
        vpl-gpu-rt
      ];
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };
  #hardware.nvidia.open = false;

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    open = false;
    modesetting.enable = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    prime = {
        sync.enable = true;
        #allowExternalGpu = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        #amdgpuBusId = "PCI:54:0:0"; # If you have an AMD iGPU
      };
  };

  # Enable the XFCE Desktop Environment.
  #services.xserver.displayManager.sessionCommands = ''
    #${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 3 0
   #'';

  # Enable i3
  #services.xserver.windowManager.i3 = {
      #enable = true;
      #extraPackages = with pkgs; [
        #dmenu #application launcher most people use
        #i3status # gives you the default i3 status bar
        #i3lock #default i3 screen locker
        #i3blocks #if you are planning on using i3blocks over i3status
     #];
    #};
  #services.xserver.displayManager.defaultSession = "none+i3";
  #services.xserver.desktopManager.xterm.enable = true;


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # enable bluetooth headphone buttons
  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.win10disk = {};
  users.users.cth = {
    isNormalUser = true;
    description = "Christoph";
    extraGroups = [
      "networkmanager"
      "wheel"
      "sys"
      "network"
      "power"
      "vboxusers"
      "docker"
      "lp"
      "win10disk"
      "disk"
      "dialout"
      "docker"
    ];
    packages = with pkgs; [
       docker_29
    #  thunderbird
     (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
        ms-vscode.cmake-tools
        ms-vscode.cpptools-extension-pack
        llvm-vs-code-extensions.vscode-clangd
        ms-vscode.cmake-tools
        ms-vscode-remote.remote-containers
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        #{
            #name = "remote-ssh-edit";
            #publisher = "dan-c-underwood.arm";
            #version = "1.7.4";
        #}
        #{
            #name = "remote-ssh-edit";
            #publisher = "marus25.cortex-debug";
            #version = "1.12.1";
        #}
        #{
            #name = "remote-ssh-edit";
            #publisher = "mcu-debug.debug-tracker-vscode";
            #version = "0.0.15";
        #}
        ];
     })
     taskwarrior3
     #teams
    ];
  };

  users.extraUsers.cth = {
      shell = pkgs.zsh;
    };
  users.defaultUserShell = pkgs.zsh;

  programs.neovim = {
     viAlias = true;
     vimAlias = true;
  };

  #programs.neovim.plugins = [
     #pkgs.vimPlugins.nvim-tree-lua
     #{
       #plugin = pkgs.vimPlugins.vim-startify;
       #config = "let g:startify_change_to_vcs_root = 0";
     #}
  #];

  # Install firefox.
  programs.firefox.enable = true;
  programs.zsh.enable = true;

  services = {
      udev.packages = with pkgs; [ 
          segger-jlink
      ];
    };
    services.udev.extraRules = ''
    SUBSYSTEM=="block", ENV{ID_PART_TABLE_UUID}=="579b23f9-843f-4fec-a246-0ed74800bef1", GROUP="win10disk", MODE="0660"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="05f9", ATTRS{idProduct}=="4204", SYMLINK+="gfe4500", MODE="0660", GROUP="dialout"
    '';
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
                "segger-jlink-qt4-874"
              ];
  nixpkgs.config.segger-jlink.acceptLicense = true;

   virtualisation.virtualbox.host.enable = true;
   #users.extraGroups.vboxusers.members = [ "cth" "win10disk" "disk" "dialout"];
   virtualisation.virtualbox.host.enableExtensionPack = true;

   virtualisation.docker.enable = true;
  #console config
  fonts.packages = with pkgs; [nerd-fonts.jetbrains-mono];
  fonts.fontDir.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     neovim
     xclip
     devbox
     vimPlugins.vim-plug
     git
     just
     tmux
     gcc13
     clang-tools
     clang
     ninja
     #gcc-arm-embedded-13
     cmake
     #llvmPackages_19.clang-unwrapped
     segger-jlink
     zsh
     oh-my-zsh
     #nerdfonts
     autorandr
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

hardware.printers = {
  ensurePrinters = [
    {
      name = "MFP_Sharp_3";
      location = "home";
      deviceUri = "ipp://10.65.0.56:631/ipp";
      model = "everywhere";
    }
  ];
  ensureDefaultPrinter = "MFP_Sharp_3";
};
  # auto discovery of network printers
  # disable because it is dangerous
  #services.avahi = {
    #enable = true;
    #nssmdns4 = true;
    #openFirewall = true;
  #};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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
  system.stateVersion = "24.11"; # Did you read the comment?

}
