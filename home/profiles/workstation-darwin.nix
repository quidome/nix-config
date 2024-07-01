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
      unset SSH_AGENT_PID
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent
    '';
  };
}
