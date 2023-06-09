{ pkgs, lib, ... }: {
  # Nix configuration ------------------------------------------------------------------------------

  imports = [
    ./system-vars.nix
  ];

  nix.settings.substituters = [ "https://cache.nixos.org/" ];
  nix.settings.trusted-users = [ "@admin" ];
  nix.configureBuildUsers = true;

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  programs.nix-index.enable = true;

  # Fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    fira-code
    source-code-pro
    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
      ];
    })
  ];

  programs.gnupg.agent.enable = true;

  # Allow touchid to be used for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
}
