{
  description = "quidome's linux nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {self, ...} @ inputs: let
    args = inputs;
    system = "x86_64-linux";

    pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = ["electron-27.3.11"];
      };
    };

    mkHost = user: host:
      inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          inputs.disko.nixosModules.disko
          {_module.args = args;}
          ./shared
          ./nixos
          ./hosts/${host}/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = {...}: {
                imports = [
                  ./shared
                  ./home
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
    nixosConfigurations = {
      beast = mkHost "quidome" "beast";
      coolding = mkHost "quidome" "coolding";
      nimbus = mkHost "quidome" "nimbus";
      truce = mkHost "quidome" "truce";

      # Bootable images
      baseIso = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./shared/secrets.nix
          ./live-image/base.nix
        ];
      };
      bcachefsIso = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
          ./shared/secrets.nix
          ./live-image/bcachefs.nix
        ];
      };
    };
  };
}
