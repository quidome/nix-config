{pkgs, ...}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  config = {
    home.stateVersion = "25.05";
    home.packages = with pkgs; [
      # devops
      jetbrains.idea-community
      ktlint
      postgresql
      temurin-bin-21
      kubectl
      kustomize
      kubernetes-helm
      cilium-cli
      k9s

      # multimedia
      kdePackages.kdenlive

      # games
      openttd
      zeroad

      # printing
      blender
      orca-slicer
    ];

    services.shikane.enable = false;

    wayland.windowManager.hyprland.settings.monitor = [
      ",preferred,auto,auto"
      "DP-1, disable"
    ];
  };
}
