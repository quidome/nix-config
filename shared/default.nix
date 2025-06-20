{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.settings;
in {
  options.settings = {
    gui = mkOption {
      type = with types;
        enum [
          "none"
          "gnome"
          "hyprland"
          "plasma"
          "sway"
        ];
      default = "none";
      description = ''
        Which gui to use. Gnome or Plasma will install the entire desktop environment. Sway will install the bare minumum.
        Defaults to `none`, which makes the system headless.
      '';
      example = "plasma";
    };
    preferQt = mkOption {
      default = false;
      description = ''
        Whether to prefer QT toolkit over GTK.

        Influences things like which version of libre office to install.
      '';
      type = types.bool;
    };

    profile.headless = mkEnableOption "headless";
    profile.workstation = mkEnableOption "workstation";

    wayland.enable = mkEnableOption "wayland";
  };

  config = {
    settings.preferQt = builtins.elem cfg.gui ["plasma"];
    settings.profile.headless = cfg.gui == "none";
    settings.profile.workstation = !cfg.profile.headless;
    settings.wayland.enable = builtins.elem cfg.gui ["gnome" "hyprland" "plasma" "sway"];
  };
}
