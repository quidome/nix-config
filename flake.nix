{
  description = "quidome's linux nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    claude-code.url = "github:sadjow/claude-code-nix";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: let
    system = "x86_64-linux";

    mkPkgs = nixpkgs:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    pkgs = mkPkgs inputs.nixpkgs;
    pkgsUnstable = mkPkgs inputs.unstable;

    mkHost = user: host:
      inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          inputs.disko.nixosModules.disko
          {
            _module.args =
              inputs
              // {
                inherit pkgsUnstable;
                desktopUser = user;
              };
          }
          ./modules/shared
          ./modules/system
          ./hosts/${host}/shared.nix
          ./hosts/${host}/system.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = {...}: {
                imports = [
                  inputs.nix-index-database.homeModules.nix-index
                  ./modules/shared
                  ./modules/home
                  ./hosts/${host}/shared.nix
                  ./hosts/${host}/home.nix
                ];
                home = {
                  username = user;
                  homeDirectory = "/home/${user}";
                };
              };
            };
          }
        ];
      };
  in {
    formatter.${system} = pkgs.alejandra;

    checks.${system} = let
      # Fails on a secret in a plain file; see docs/product/secrets.md.
      leakGuard = pkgs.writeShellApplication {
        name = "leak-guard";
        runtimeInputs = with pkgs; [coreutils findutils gawk gnugrep];
        text = builtins.readFile ./scripts/leak-guard.sh;
      };
      leakGuardTest = pkgs.writeShellApplication {
        name = "leak-guard-test";
        runtimeInputs = with pkgs; [coreutils];
        text = builtins.readFile ./scripts/leak-guard-test.sh;
      };
    in {
      lint =
        pkgs.runCommand "lint" {
          nativeBuildInputs = with pkgs; [alejandra deadnix statix];
        } ''
          cd ${./.}
          alejandra --check .
          statix check .
          deadnix --fail .
          touch $out
        '';

      leak-guard = pkgs.runCommand "leak-guard" {} ''
        ${leakGuard}/bin/leak-guard ${./.}
        touch $out
      '';

      leak-guard-test = pkgs.runCommand "leak-guard-test" {} ''
        ${leakGuardTest}/bin/leak-guard-test ${leakGuard}/bin/leak-guard
        touch $out
      '';
    };

    nixosConfigurations = {
      nimbus = mkHost "quidome" "nimbus";
      truce = mkHost "quidome" "truce";
      bea = mkHost "quidome" "bea";

      # Bootable images
      baseIso = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./live-image/base.nix
        ];
      };
      bcachefsIso = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
          ./live-image/bcachefs.nix
        ];
      };
    };
  };
}
