{lib}: let
  _ = lib;
in {
  config = {
    windowrule = [
      "float, class:^(polkit-gnome-authentication-agent-1)$"
      "size 741 288, class:^(polkit-gnome-authentication-agent-1)$"
      "center, class:^(polkit-gnome-authentication-agent-1)$"
    ];

    windowrulev2 = [
      "suppressevent maximize, class:.*"
      "float, class:org.pulseaudio.pavucontrol"
      "float, class:nm-connection-editor"
      "workspace 4 silent, class:(Element)"
      "workspace 4 silent, class:(Signal)"
      "workspace 5 silent, class:(Spotify)"
    ];
  };
}
