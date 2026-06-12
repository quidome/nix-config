{lib}: let
  hyprWaybar = import ./hyprland/waybar.nix {inherit lib;};
in
  hyprWaybar
  // {
    systemd.targets = ["graphical-session.target"];
    settings.mainBar =
      (removeAttrs hyprWaybar.settings.mainBar ["hyprland/workspaces"])
      // {
        modules-left = ["niri/workspaces"];
        "niri/workspaces" = {
          all-outputs = true;
          disable-scroll = true;
          format = "{icon}";
        };
      };
  }
