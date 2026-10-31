{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "niri") {
    programs.niri.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      # niri starts this for X11 apps when it is in PATH.
      xwayland-satellite

      # Send notifications from scripts (notify-send).
      libnotify
      # Media keys; avizo handles volume and brightness keys with a pop-up.
      playerctl

      # Plasma brings its own apps; these replace them in niri.
      file-roller
      loupe
      nautilus
      papers

      # Icons and fonts for sessions without their own theme.
      adwaita-icon-theme
    ];

    fonts.packages = [pkgs.noto-fonts];

    # Printer settings app and USB printer setup, as Plasma and GNOME have.
    programs.system-config-printer.enable = lib.mkIf config.services.printing.enable (lib.mkDefault true);

    # Trash, phones (MTP) and network shares in nautilus and the file picker.
    services.gvfs.enable = lib.mkDefault true;

    services.greetd = {
      enable = lib.mkDefault true;
      useTextGreeter = lib.mkDefault true;
      # Do not remember users on the login screen.
      settings.default_session.command = lib.mkDefault "${lib.getExe pkgs.tuigreet} --time --asterisks --cmd ${lib.getExe' config.programs.niri.package "niri-session"}";
    };
  };
}
