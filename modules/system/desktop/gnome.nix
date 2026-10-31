{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.settings.gui == "gnome") {
    environment.systemPackages = with pkgs; [
      geary
      gnome-tweaks
      pavucontrol
      gnomeExtensions.caffeine
      gnomeExtensions.display-configuration-switcher
    ];

    services = {
      xserver.enable = lib.mkDefault true;
      desktopManager.gnome.enable = lib.mkDefault true;
      displayManager.gdm.enable = lib.mkDefault true;

      # Home Manager's gpg-agent provides the SSH agent; keep gnome-keyring's GCR agent off.
      gnome.gcr-ssh-agent.enable = false;
    };
  };
}
