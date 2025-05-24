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
          inputs.disko.nixosModules.disko
          { _module.args = args; }
          ./hosts/${host}/configuration.nix

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
          inputs.disko.nixosModules.disko
          { _module.args = args; }
          ./hosts/${host}/configuration.nix
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
        "quidome@coolding" = mkHome "quidome" "coolding";
        "quidome@truce" = mkHome "quidome" "truce";
      };

      nixosConfigurations = {
        nimbus = mkFull "quidome" "nimbus";
        beast = mkFull "quidome" "beast";
        coolding = mkHost "coolding";
        truce = mkHost "truce";
      };
    };
}
