{ conf, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    bottom
    curl
    dog
    fd
    fzf
    ripgrep
    wget

    # Useful nix related tools
    cachix # adding/managing alternative binary caches hosted by Cachix
    comma # run software from without installing it
    niv # easy dependency management for nix projects
    nixpkgs-fmt
    rnix-lsp # nix language server
  ];

  programs.bat.enable = true;
  programs.bat.config.theme = "DarkNeon";
  programs.bat.config.style = "header,snip";

  programs.exa.enable = true;
  programs.exa.enableAliases = true;

  programs.ssh.extraConfig = "AddKeysToAgent yes";

  programs.zellij.enable = true;
  programs.zellij.settings.theme = "nord";
  programs.zellij.settings.default_layout = "compact";
}
