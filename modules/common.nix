{ ... }:
{
  programs = {
    zsh.enable = true;
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
    ssh.startAgent = false;
  };
}
