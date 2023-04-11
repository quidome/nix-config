{ config, pkgs, lib, ... }:
{
  imports = [
    ../../home
    ./vars.nix
  ];

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      git-crypt
    ];
  };

  programs.home-manager.enable = true;
  programs = {
    alacritty.enable = true;

    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    firefox.enable = true;
    git.enable = true;

    htop.enable = true;
    htop.settings.show_program_path = true;

    ssh.enable = true;

    tmux.enable = true;

    zsh.enable = true;
  };
}
