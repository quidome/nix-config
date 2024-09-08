{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "install-bcachefs" (builtins.readFile ./nixos-bcachefs-root-efi.sh))
    (writeShellScriptBin "install-zfs-efi" (builtins.readFile ./nixos-zfs-root-efi.sh))
    (writeShellScriptBin "install-zfs-mbr" (builtins.readFile ./nixos-zfs-root-mbr.sh))
  ];
}
