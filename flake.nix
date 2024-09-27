{
  description = "quidome's linux nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nixos-cosmic.inputs.nixpkgs.follows = "nixpkgs";
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
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = import ./hosts/${host}/home.nix;
          }
        ];
      };

    in
    {
      nixosConfigurations = {
        # nimbus = mkHost "nimbus";
        nimbus = inputs.nixpkgs.lib.nixosSystem {
          inherit pkgs;
          modules = [
            {
              nix.settings = {
                substituters = [ "https://cosmic.cachix.org/" ];
                trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
              };
            }
            inputs.nixos-cosmic.nixosModules.default
            ./hosts/nimbus/system.nix
          ];
        };

        beast = mkFull "beast";
        coolding = mkFull "coolding";
        truce = mkFull "truce";
      };
    };
}
