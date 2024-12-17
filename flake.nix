{
  description = "quidome's linux nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "electron-27.3.11" ];
        };
      };
      args = inputs;

      mkFull = user: host: inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          { _module.args = args; }
          ./hosts/${host}/system.nix

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${user} = import ./hosts/${host}/home.nix;
          }
        ];
      };

      mkHost = host: inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          { _module.args = args; }
          ./hosts/${host}/system.nix
        ];
      };

      mkHome = user: host: inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          { _module.args = args; }
          ./hosts/${host}/home.nix
          {
            home = {
              username = user;
              homeDirectory = "/home/${user}";
            };
          }
        ];
      };

    in
    {
      homeConfigurations = {
        "quidome@nimbus" = mkHome "quidome" "nimbus";
        "quidome@beast" = mkHome "quidome" "beast";
        "quidome@coolding" = mkHome "quidome" "coolding";
        "quidome@truce" = mkHome "quidome" "truce";
      };

      nixosConfigurations = {
        nimbus = mkFull "quidome" "nimbus";
        beast = mkHost "beast";
        coolding = mkHost "coolding";
        truce = mkHost "truce";
      };
    };
}
