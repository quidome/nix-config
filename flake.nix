{
  description = "quidome's linux nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
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

      mkFull = host: user: inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          { _module.args = args; }
          ./hosts/${host}/system.nix

          inputs.home-manager.nixosModules.home-manager
          {
            # nixpkgs = nixpkgsConfig;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = import ./hosts/${host}/home.nix;
          }
        ];
      };

    in
    {
      nixosConfigurations = {
        nimbus = mkFull "nimbus" "quidome";
        beast = mkFull "beast" "quidome";
        coolding = mkFull "coolding" "quidome";
        truce = mkFull "truce" "quidome";
      };
    };
}
