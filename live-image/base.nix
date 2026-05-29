{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (config.settings) authorizedKeys;
in {
  options.settings.authorizedKeys = mkOption {type = types.listOf types.str;};

  config = {
    nix.settings.experimental-features = ["nix-command" "flakes"];
    boot.zfs.forceImportRoot = false;

    environment.systemPackages = with pkgs; [
      fd
      git
      helix
      htop
    ];

    networking.networkmanager.enable = true; # nmtui for wi-fi

    systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];

    users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
    users.users.nixos.openssh.authorizedKeys.keys = authorizedKeys;
  };
}
