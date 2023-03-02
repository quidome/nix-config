{ nixpkgs, config, pkgs, lib, ... }:

{
  home.packages = [
    pkgs.syncthing
  ];

  launchd.agents.syncthing = {
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
}
