{pkgs}: {
  Unit = {
    Description = "GNOME polkit authentication agent";
    After = ["hyprland-session.target"];
    PartOf = ["hyprland-session.target"];
    ConditionEnvironment = "WAYLAND_DISPLAY";
  };

  Service = {
    ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    Restart = "on-failure";
  };

  Install.WantedBy = ["hyprland-session.target"];
}
