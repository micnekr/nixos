# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let homeDirectory = "/home/mic";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "thinkpad"; # Define your hostname.

  # Allow wireguard connections through firewall
  networking.firewall.checkReversePath = "loose";
  # Set your time zone.
  time.timeZone = "Europe/London";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # TODO: change this back by removing the line in order to improve battery life.
  # Can only do this once the issue with deep sleep is fixed
  # boot.kernelParams = [ "mem_sleep_default=deep" ];
  boot.kernelParams = [ "mem_sleep_default=s2idle" ];

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Auto-detection of printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.printing.logLevel = "debug";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mic = {
    isNormalUser = true;
    description = "mic";
    extraGroups = [
      "networkmanager"
      "wheel"
      # For kanata
      "uinput" "input"
    ];
  };

  services.tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 50;

         #Optional helps save long term battery health
         START_CHARGE_THRESH_BAT0 = 70; # 40 and below it starts to charge
         STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

        };
  };
  services.power-profiles-daemon.enable = false;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/mic/.config/nixos";
  };

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

  services.kanata = {
    enable = true;
    # /dev/input/by-path/platform-i8042-serio-0-event-kbd
    keyboards = {
      base = {
        extraDefCfg = ''
          danger-enable-cmd yes
          process-unmapped-keys yes
        '';
        config = (builtins.readFile ../../config/kanata.kbd);
      };
    };
    package = pkgs.kanata-with-cmd;
  };

  # Suspend
  # https://github.com/NixOS/nixpkgs/issues/409934
  environment.systemPackages = [ 
    # pkgs.pmutils 
    pkgs.wireguard-tools 
    pkgs.networkmanager
  ];
  # systemd.services."systemd-suspend" = {
  #   description = "System Suspend with pm-suspend";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     Environment = "PATH=${pkgs.pmutils}/bin";
  #     ExecStart = [
  #       ""
  #       "${pkgs.pmutils}/bin/pm-suspend"
  #     ];
  #   };
  # };
  
  services.fwupd.enable = true;

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  networking.nameservers = [
    "9.9.9.9"
  ];

  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [
      "9.9.9.9"
    ];
    dnsovertls = "true";
  };
}
