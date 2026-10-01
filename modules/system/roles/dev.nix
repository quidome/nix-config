{
  claude-code,
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.settings;
in {
  config = lib.mkIf cfg.roles.dev.enable {
    environment.systemPackages = with pkgs;
      [
        # git
        gh
        git-repo-updater
        gitui
        lazygit
        mani

        # devops tooling
        cilium-cli
        helmfile
        k9s
        kubectl
        kubectx
        kubernetes-helm
        kubeseal
        kustomize
        stern

        # languages and linters
        ktlint
        pandoc
        python3
        shellcheck
        temurin-bin-21
        yamllint

        # coding agents
        claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgsUnstable.pi-coding-agent
      ]
      ++ lib.optionals (cfg.gui != "none") [
        adoptopenjdk-icedtea-web
        plantuml
        vscodium
      ];
  };
}
