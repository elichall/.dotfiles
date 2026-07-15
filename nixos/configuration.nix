{ config, pkgs, ... }:
let 
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Home Manager
      (import "${home-manager}/nixos")
    ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.elichall = import ./home.nix;
  };
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 2;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.elichall = {
    isNormalUser = true;
    description = "Elijah";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    packages = with pkgs; [];
  };

  services.displayManager.ly = {
    enable = true;

    settings = {
      animation = "matrix"; # TUI background effect
      bigclock = true;
    };
  };

  environment.interactiveShellInit = ''
    if [ -e "#HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" 
    fi
  '';

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # enable bash
  programs.bash.enable = true;

  environment.sessionVariables = {
    WLR_RENDER_ALLOW_SOFTWARE = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Audio system enable
  security.rtkit.enable = true;
  services.pipewire = {
	enable = true;
	alsa.enable = true;
	alsa.support32Bit = true;
	pulse.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  	# system resources
	  gcc
	  ripgrep
	  unzip
	  wl-clipboard
	  grimblast
    waypaper
    awww
    quickshell
    waybar
    # tailscale
    # hypridle

    # command line resources
    tree-sitter
    fzf
    zoxide
    blesh
    starship
    fastfetch
    git
    # docker
    # podman

    # tui
    tmux
    neovim
    yazi
    # wlctl
    # bluetui
    # btop
    # gdu

    # apps
    firefox
    ghostty
    rofi
    rofi-calc
    rofi-power-menu
    # bitwarden-cli
    # moonlight-qt
    # obsidian
    # obs-studio

    # fluff
    # cava
    # cmatrix
    # cmatrix
    # cowsay
    # lolcat
    # pipes
    # sl
    # fortune
  ];

  nixpkgs.config.permittedInsecurePackages = [
  	"electron-39.8.10"
	];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.spice-vdagentd.enable = true;

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

  zramSwap.enable = true;

  system.stateVersion = "26.05"; # Did you read the comment?

}
