{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.settings.gui != "none") {
    hardware.bluetooth.input.General.UserspaceHID = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    services = {
      flatpak.enable = lib.mkDefault true;
      pipewire.enable = lib.mkDefault true;
    };
  };
}
