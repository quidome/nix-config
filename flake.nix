# I did not invent this myself, this was starting point:
# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
#
# Initially I will just manage my macbook this way and when I'm
# more comfortable I'll look into migrating the other systems to flakes as well.
{
  description = "quidome's nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , darwin
    , nixpkgs
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
        config = { allowUnfree = true; };
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
        gaming-rig-rgb = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/gaming-rig-rgb/configuration.nix

            home-manager.nixosModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.quidome = import ./hosts/gaming-rig-rgb/home.nix;
            }
          ];
        };
        truce = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/truce/configuration.nix

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
          # system = "aarch64-darwin";
          modules = [
            ./hosts/LMAC-F47VNQXX1G/configuration.nix

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
