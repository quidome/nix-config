{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  hyprlandEnabled = config.settings.gui == "hyprland";
  networkmanagerEnabled = config.networking.networkmanager.enable;
  tailscaleEnabled = config.services.tailscale.enable;
in {
  config = mkIf hyprlandEnabled {
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
    services.greetd = {
      enable = true;
      settings.default_session = {
        user = "greeter";
        command = lib.mkDefault "${pkgs.greetd.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
      };
    };

    services.gnome.gnome-keyring.enable = true;

    services.logind.extraConfig = "HandlePowerKey=suspend";

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
