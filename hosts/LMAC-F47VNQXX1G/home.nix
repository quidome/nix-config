{ pkgs, ... }:
{
  imports = [
    ./home-brew.nix
    ./home-vars.nix

    ../../home
  ];

  home = {
    language.base = "en_IE.UTF-8";
    language.ctype = "en_IE.UTF-8";
    stateVersion = "24.05";
    packages = with pkgs; [
      # DevOps
      colima
      docker-client
      docker-compose
      docker-credential-helpers
      envsubst
      fnm
      k9s
      kubectx
      stern
    ];

    sessionPath = [
      "/Applications/IntelliJ IDEA.app/Contents/MacOS"
    ];
  };

  programs.zsh = {
    initExtra = ''
      eval "$(fnm env --use-on-cd)";
    '';

    shellAliases = {
      nix-update = "darwin-rebuild switch --flake $HOME/dev/github.com/quidome/nix-config";
      idea = "open -na \"IntelliJ IDEA.app\" --args \"$@\"";
    };
  };
}
