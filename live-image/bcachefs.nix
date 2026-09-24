{pkgs, ...}: {
  imports = [./base.nix];

  boot.supportedFilesystems = ["bcachefs"];

  environment.systemPackages = with pkgs; [
    keyutils
    bcachefs-tools
  ];
}
