{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "niri") {
    # Terminal and launcher used by niri's default key bindings.
    programs = {
      alacritty.enable = lib.mkDefault true;
      fuzzel.enable = lib.mkDefault true;
    };

    # Password prompt for polkit, started with graphical-session.target.
    services.polkit-gnome.enable = lib.mkDefault true;
  };
}
