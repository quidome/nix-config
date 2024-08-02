{ pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  config = lib.mkIf (isDarwin) {
    home.packages = with pkgs; [
      pinentry_mac
    ];

    home.file.".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${lib.getExe pkgs.pinentry_mac}
      enable-ssh-support

      default-cache-ttl 7200
      max-cache-ttl 43200

      default-cache-ttl-ssh 7200
      max-cache-ttl-ssh 43200
    '';

    programs.gpg.enable = true;
    programs.zsh.initExtra = ''
      # Configure gpg/ssh
      unset SSH_AGENT_PID
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent

      # Add function to update nixpkgs index
      download_nixpkgs_cache_index () {
        location=~/.cache/nix-index
        filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr A-Z a-z)"
        mkdir -p "$location"
        # -N will only download a new version if there is an update.
        wget -P "$location" -q -N https://github.com/nix-community/nix-index-database/releases/latest/download/$filename
        ln -f "$location/$filename" "$location/files"
      }
    '';
  };
}
