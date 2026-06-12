{lib}: let
  hyprWaybar = import ./hyprland/waybar.nix {inherit lib;};
in
  hyprWaybar
  // {
    # Start after Niri itself so Waybar sees the Wayland session environment.
    systemd.targets = ["niri.service"];
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
