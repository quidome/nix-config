{
  description = "quidome's linux nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    pi.url = "github:lukasl-dev/pi.nix";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: let
    args = inputs;
    system = "x86_64-linux";

    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    mkHost = user: host:
      inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          inputs.disko.nixosModules.disko
          {_module.args = args;}
          ./modules/shared
          ./modules/system
          ./hosts/${host}/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = {...}: {
                imports = [
                  inputs.pi.homeModules.default
                  ./modules/shared
                  ./modules/home
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
      nimbus = mkHost "quidome" "nimbus";
      truce = mkHost "quidome" "truce";
      bea = mkHost "quidome" "bea";

      # Bootable images
      baseIso = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./modules/shared/secrets.nix
          ./live-image/base.nix
        ];
      };
      bcachefsIso = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
          ./modules/shared/secrets.nix
          ./live-image/bcachefs.nix
        ];
      };
    };
  };
}
