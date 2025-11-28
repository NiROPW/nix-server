{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # mount hdd
  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-label/media";  # uses the label from mkfs
    fsType = "ext4";
    options = [ "defaults" ];
  };

  # networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 139 445 8920 5201 ];
  networking.firewall.allowedUDPPorts = [ 137 138 1900 7359 ];

  # system settings
  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;

  # keep gui installed but disabled
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = false;
  services.xserver.desktopManager.cinnamon.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # main user
  users.users.winterfell = {
    isNormalUser = true;
    description = "Remi D'hooge";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # services
  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.samba = {
    enable = true;
    settings = {
      Media = {
        path = "/mnt/media";
        browseable = true;
        writeable = true;
        guestOk = false;
        validUsers = [ "winterfell" ];
        # hide lost+found folder for clients
        vetoFiles = [ "lost+found" ];
        hideUnreadable = true;
      };
    };
  };
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "winterfell";
    group = "users";
  };
  services.transmission = {
    enable = true;
    openRPCPort = true;
    openFirewall = true;
    user = "winterfell";
    group = "users";
    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist = "127.0.0.1,100.*.*.*,192.168.*.*";
      rpc-host-whitelist-enabled = false;
    };
  };
  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "winterfell";
    group = "users";
  };
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "winterfell";
    group = "users";
  };
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.vanillaSurvival = {
      enable = true;
      package = pkgs.minecraftServers.paper-1_21_10;
      whitelist = {
        Casfex = "370e4237-029a-4ac1-b7dd-b08aad482267";
        azer_aspect = "bea87729-24a4-46bd-8d09-a51221e81840";
      };
      operators = {
        Casfex = {
          uuid = "370e4237-029a-4ac1-b7dd-b08aad482267";
          level = 4;
        };
      };
      serverProperties = {
        gamemode = 0;
        motd = "#cancelAzer";
        white-list = false;
        max-players = 10;
        allow-flight = true;
        difficulty = 2;
        view-distance = 12;
      };

      jvmOpts = "-Xms4G -Xmx4G -XX:+UseG1GC";
    };
  };

  # packages
  environment.systemPackages = with pkgs; [
    parted
    git
  ];

  system.stateVersion = "25.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
