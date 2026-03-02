{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.settings.desktop.hyprland;
  networkmanagerEnabled = config.networking.networkmanager.enable;
  tailscaleEnabled = config.services.tailscale.enable;
in {
  options.settings.desktop.hyprland = {
    enable = mkEnableOption "hyprland";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        # hyprland deps
        avizo
        hyprpicker
        hyprcursor
        hyprlock
        hypridle
        hyprpaper
        libnotify
        libsecret
        seahorse
        waybar
        wdisplays

        imv
        grimblast
        playerctl
        shikane
        wev

        kdePackages.polkit-kde-agent-1

        (mkIf networkmanagerEnabled networkmanagerapplet)
        (mkIf tailscaleEnabled tailscale-systray)
      ];
    };

    programs.gnupg.agent.enableSSHSupport = true;
    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;
    programs.hyprlock.enable = true;
    programs.thunar.enable = true;

    security.pam.services.greetd.enableGnomeKeyring = true;
    security.pam.services.hyprlock = {};

    services.auto-cpufreq.enable = true;
    services.gnome.gnome-keyring.enable = true;
    services.greetd = {
      enable = true;
      settings.default_session = {
        user = "greeter";
        command = lib.mkDefault "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
      };
    };
    services.logind.settings.Login = {HandlePowerKey = "suspend";};

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
