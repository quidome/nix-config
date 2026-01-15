{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.qm.home.desktop.niri;
  networkmanagerEnabled = config.networking.networkmanager.enable;
  tailscaleEnabled = config.services.tailscale.enable;
in {
  options.qm.home.desktop.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alacritty
      fuzzel
      swaylock
      mako
      swayidle
      unstable.noctalia-shell
      swaybg
      waybar
      wdisplays

      xwayland-satellite
      kdePackages.polkit-kde-agent-1

      (mkIf networkmanagerEnabled networkmanagerapplet)
      (mkIf tailscaleEnabled tailscale-systray)
    ];

    hardware.bluetooth.enable = mkDefault true;

    programs.gnupg.agent.enableSSHSupport = true;
    programs.niri.enable = true;
    programs.thunar.enable = true;

    security.polkit.enable = true; # polkit
    security.pam.services.greetd.enableGnomeKeyring = true;
    security.pam.services.swaylock = {};

    services.gnome.gnome-keyring.enable = true; # secret service
    services.greetd.enable = true;
    services.greetd.settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd niri-session";
    services.logind.settings.Login = {HandlePowerKey = "suspend";};
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
