# I did not invent this myself, this was starting point:
# https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050
#
# Initially I will just manage my macbook this way and when I'm
# more comfortable I'll look into migrating the other systems to flakes as well.
{
  description = "quidome's nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nixos-cosmic.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }@inputs:
    let
      inherit (inputs.darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs.lib) nixosSystem;
      inherit (inputs.nixpkgs.lib)
        attrValues optionalAttrs singleton;

      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config.allowUnfree = true;
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

      nixosConfigurations = {
        beast = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/beast/system.nix

            inputs.home-manager.nixosModules.home-manager
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

            inputs.home-manager.nixosModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.quidome = import ./hosts/coolding/home.nix;
            }
          ];
        };

        nimbus = nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs = nixpkgsConfig;

              nix.settings.substituters = [ "https://cosmic.cachix.org/" ];
              nix.settings.trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.quidome = import ./hosts/nimbus/home.nix;
            }
            inputs.home-manager.nixosModules.home-manager
            inputs.nixos-cosmic.nixosModules.default

            ./hosts/nimbus/system.nix
          ];
        };

        truce = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/truce/system.nix

            inputs.home-manager.nixosModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.quidome = import ./hosts/truce/home.nix;
            }
          ];
        };
      };

      darwinConfigurations = {
        LMAC-F47VNQXX1G = darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/LMAC-F47VNQXX1G/darwin.nix

            inputs.home-manager.darwinModules.home-manager
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
