{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.my.profile == "workstation") {
    fonts.fonts = with pkgs; [
      fira-code
      source-code-pro
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
        ];
      })
    ];

    services.flatpak.enable = true;
    services.openssh.enable = true;
    services.pipewire.enable = true;
  };
}
