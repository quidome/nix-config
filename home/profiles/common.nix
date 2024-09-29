{ config, lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # system
      bottom
      fd
      fzf
      gnupg
      ripgrep

      # network
      curl
      dogdns
      wget

      # devops
      gitui
      go
      shellcheck
      yq-go

      # tools
      bitwarden-cli
      gopass
      jless
      jq
      rcm

      # Useful nix related tools
      cachix # adding/managing alternative binary caches hosted by Cachix
      comma # run software from without installing it
      niv # easy dependency management for nix projects
      nixpkgs-fmt
    ];

    sessionPath = [
      "${config.home.homeDirectory}/bin"
      "${config.home.homeDirectory}/go/bin"
      "${config.home.homeDirectory}/.cargo/bin"
    ];

    sessionVariables = {
      DEV_PATH = "${config.home.homeDirectory}/dev";
    };
  };

  programs.bat.enable = true;
  programs.bat.config.theme = "DarkNeon";
  programs.bat.config.style = "header,snip";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.eza.enable = true;
  programs.eza.enableZshIntegration = true;

  programs.git.enable = true;

  programs.helix.enable = true;

  programs.home-manager.enable = true;

  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  programs.ssh.enable = true;
  programs.ssh.extraConfig = "AddKeysToAgent yes";

  programs.zellij.enable = lib.mkDefault true;

  programs.zoxide.enable = true;
  programs.zoxide.options = [ "--cmd j" ];

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.initExtraBeforeCompInit = "fpath+=($HOME/.zsh/completion/)";
}
