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
