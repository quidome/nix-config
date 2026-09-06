{pkgs, ...}: {
  imports = [
    ./shared.nix
    ./home-vars.nix
  ];

  home.stateVersion = "26.05";

  programs.zed-editor.userSettings.buffer_font_size = 13;

  home.packages = with pkgs; [discord];
}
