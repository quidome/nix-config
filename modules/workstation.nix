{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.my.profile == "workstation") {
    fonts.packages = with pkgs; [
      fira-code
      source-code-pro
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "FiraCode"
        ];
      })
    ];

    services.flatpak.enable = true;
    services.openssh.enable = true;
    services.pipewire.enable = true;
  };
}
