{ config, pkgs, lib, ... }:
with lib;
let
  isDarwin = pkgs.stdenv.isDarwin;
  syncthingEnabled = config.my.syncthing.enable;
in
{
  config = mkIf syncthingEnabled {
    # Linux setup for syncthing
    services.syncthing = mkIf (! isDarwin) {
      enable = true;
    };


    # Darwin setup for syncthing
    home.packages = with pkgs; mkIf isDarwin [ syncthing ];
    launchd.agents.syncthing = mkIf isDarwin {
      # whether to enable the LaunchAgent
      enable = true;

      # LaunchAgent configuration translated to the Nix Expression Language
      config = {
        ProgramArguments = [ "${pkgs.syncthing}/bin/syncthing" "-no-browser" "-no-restart" ];
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        ProcessType = "Background";
      };
    };
  };
}
