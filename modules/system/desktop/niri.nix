{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "niri") {
    programs.niri.enable = lib.mkDefault true;

    # niri starts this for X11 apps when it is in PATH.
    environment.systemPackages = [pkgs.xwayland-satellite];

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
