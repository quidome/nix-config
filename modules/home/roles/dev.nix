{
  config,
  lib,
  ...
}: let
  cfg = config.settings;
in {
  config = lib.mkIf cfg.roles.dev.enable (lib.mkMerge [
    {
      home = {
        sessionPath = lib.mkAfter [
          "${config.home.homeDirectory}/go/bin"
          "${config.home.homeDirectory}/.cargo/bin"
        ];

        sessionVariables = {
          DEV_PATH = "${config.home.homeDirectory}/dev";
          GOBIN = "${config.home.homeDirectory}/.local/bin";
          PI_CODING_AGENT_DIR = "${config.home.homeDirectory}/dev/github.com/quidome/pi-config";
          PI_EXTENSIONS = "${config.home.homeDirectory}/dev/github.com/quidome/pi-extensions/extensions";
        };
      };

      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        jujutsu = {
          enable = true;
          ediff = true;
        };

        zsh.shellAliases = {
          "k" = "kubectl";
          "kc" = "kubectx";
          "kn" = "kubens";
          "kseal" = "kubeseal --controller-namespace kube-system --controller-name sealed-secrets";
        };
      };
    }

    (lib.mkIf (cfg.gui != "none") {
      programs = {
        emacs.enable = lib.mkDefault true;
        zed-editor.enable = lib.mkDefault true;
      };
    })
  ]);
}
