{
  config,
  lib,
  ...
}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "25.11";

  settings = {
    terminalFont.size = 10;
  };


  dconf.settings."org/gnome/desktop/peripherals/mice/045e:0800" = {
    natural-scroll = false;
  };

  dconf.settings."org/gnome/desktop/peripherals/mice/046d:c05a" = {
    left-handed = true;
  };

}
