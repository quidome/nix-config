{
  description = "quidome's linux nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
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

    mkNixos = host:
      inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          inputs.disko.nixosModules.disko
          {_module.args = args;}
          ./shared
          ./nixos
          ./hosts/${host}/configuration.nix
        ];
      };

    mkHome = user: host:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          {_module.args = args;}
          ./shared
          ./home
          ./hosts/${host}/home.nix
          {
            home = {
              username = user;
              homeDirectory = "/home/${user}";
            };
          }
        ];
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
    homeConfigurations = {
      "quidome@beast" = mkHome "quidome" "beast";
      "quidome@coolding" = mkHome "quidome" "coolding";
      "quidome@nimbus" = mkHome "quidome" "nimbus";
      "quidome@truce" = mkHome "quidome" "truce";
    };

    nixosConfigurations = {
      beast = mkNixos "beast";
      coolding = mkNixos "coolding";
      nimbus = mkHost "quidome" "nimbus";
      truce = mkNixos "truce";

      new = mkHost "quidome" "nimbus";

      # Bootable images
      baseIso = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./shared/secrets.nix
          ./live-image/base.nix
        ];
      };
    };
  };
}
