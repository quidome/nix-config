{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  authorizedKeys = config.settings.authorizedKeys;
in {
  options.settings.authorizedKeys = mkOption {type = types.listOf types.str;};

  config = {
    nix.settings.experimental-features = ["nix-command" "flakes"];

    boot.supportedFilesystems = [
      "bcachefs"
      # "btrfs"
      # "cifs"
      # "f2fs"
      # "ntfs"
      # "vfat"
      # "xfs"
      # "zfs"
    ];

    environment.systemPackages = with pkgs; [
      fd
      git
      helix
      htop
      keyutils
      bcachefs-tools
    ];

    networking.networkmanager.enable = true; # nmtui for wi-fi
    networking.wireless.enable = lib.mkForce false;

    systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];

    users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
    users.users.nixos.openssh.authorizedKeys.keys = authorizedKeys;
  };
}
