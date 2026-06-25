{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  isWorkstation = config.settings.gui != "none";
  electronSecretStoreFlags = "--password-store=gnome-libsecret";

  elementDesktop = pkgs.symlinkJoin {
    name = "element-desktop";
    paths = [pkgs.element-desktop];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm $out/bin/element-desktop
      makeWrapper ${lib.getExe pkgs.element-desktop} $out/bin/element-desktop \
        --add-flags "${electronSecretStoreFlags}"

      rm $out/share/applications/element-desktop.desktop
      cp ${pkgs.element-desktop}/share/applications/element-desktop.desktop $out/share/applications/element-desktop.desktop
      substituteInPlace $out/share/applications/element-desktop.desktop \
        --replace-fail "Exec=element-desktop %u" "Exec=element-desktop ${electronSecretStoreFlags} %u"
    '';
  };

  signalDesktop = pkgs.symlinkJoin {
    name = "signal-desktop";
    paths = [pkgs.signal-desktop];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm $out/bin/signal-desktop
      makeWrapper ${lib.getExe pkgs.signal-desktop} $out/bin/signal-desktop \
        --add-flags "${electronSecretStoreFlags}"

      rm $out/share/applications/signal.desktop
      cp ${pkgs.signal-desktop}/share/applications/signal.desktop $out/share/applications/signal.desktop
      substituteInPlace $out/share/applications/signal.desktop \
        --replace-fail "Exec=signal-desktop %U" "Exec=signal-desktop ${electronSecretStoreFlags} %U"
    '';
  };
in {
  config = mkIf isWorkstation {
    hardware.bluetooth.input.General.UserspaceHID = mkDefault true;

    environment.systemPackages = with pkgs; [
      adoptopenjdk-icedtea-web
      cameractrls-gtk3
      firefox
      mani
      elementDesktop
      obsidian
      signalDesktop
      spotify
      pandoc
      pavucontrol
      plantuml
      v4l-utils
      vlc
      vscodium
      wl-clipboard

      # office
      libreoffice
      hunspell
      hunspellDicts.nl_NL
      hunspellDicts.en_US-large
      hunspellDicts.en_GB-large
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    services = {
      avahi = {
        enable = mkDefault true;
        nssmdns4 = mkDefault true;
        openFirewall = mkDefault true;
      };

      flatpak.enable = mkDefault true;
      pipewire.enable = mkDefault true;
      tailscale.enable = mkDefault false;

      # Enable printing and printer discovery
      printing = {
        enable = mkDefault true;
        drivers = with pkgs; [
          cups-filters
          cups-browsed
        ];
      };
    };
  };
}
