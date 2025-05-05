{ config, pkgs, lib, ... }:
let
  cfg = config.settings.profile;
in
{
  config = lib.mkIf cfg.workstation {
    home = {
      packages = with pkgs; [
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

        # devops
        jetbrains.idea-community
        temurin-bin-21
        ktlint

        # multimedia
        mpv

        # games
        openttd
        zeroad
      ];
    };

    fonts.fontconfig.enable = true;
    programs.firefox.enable = true;
    services.syncthing.enable = true;
  };
}
