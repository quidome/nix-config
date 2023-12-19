# I did not invent this myself, this was starting point:
# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
#
# Initially I will just manage my macbook this way and when I'm
# more comfortable I'll look into migrating the other systems to flakes as well.
{
  description = "quidome's nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , darwin
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , ...
    }@inputs:
    let
      inherit (darwin.lib) darwinSystem;
      inherit (nixpkgs.lib) nixosSystem;
      inherit (inputs.nixpkgs.lib)
        attrValues makeOverridable optionalAttrs singleton;

      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "electron-25.9.0" # for obsidian
        ];
        overlays = attrValues self.overlays ++ singleton (
          # Sub in x86 version of packages that don't build on Apple Silicon yet
          final: prev:
            (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
              inherit (final.pkgs-x86)
                niv# has an aarch64 build but it won't build
                purescript
                ;
            })
        );
      };
    in
    {

      nixosConfigurations = rec {
        beast = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/beast/system.nix

            home-manager.nixosModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.quidome = import ./hosts/beast/home.nix;
            }
          ];
        };

        coolding = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/coolding/system.nix

            home-manager.nixosModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.quidome = import ./hosts/coolding/home.nix;
            }
          ];
        };

        truce = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/truce/system.nix

            home-manager.nixosModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.quidome = import ./hosts/truce/home.nix;
            }
          ];
        };
      };

      darwinConfigurations = rec {
        LMAC-F47VNQXX1G = darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/LMAC-F47VNQXX1G/system.nix

            home-manager.darwinModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.qmeijer = import ./hosts/LMAC-F47VNQXX1G/home.nix;
            }
          ];
        };
      };

      # Overlays --------------------------------------------------------------- {{{
      overlays = {
        unstable-packages = final: _prev: {
          unstable = import inputs.nixpkgs-unstable {
            system = final.system;
            config.allowUnfree = true;
          };
        };
        # Overlays to add various packages into package set
        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev:
          optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs {
              system = "x86_64-darwin";
              inherit (nixpkgsConfig) config;
            };
          };
      };
    };
}
