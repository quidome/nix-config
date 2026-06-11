{
  description = "quidome's linux nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    catppuccin.url = "github:catppuccin/nix/release-26.05";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    snappy-switcher.url = "github:OpalAayan/snappy-switcher";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs: let
    args = inputs;
    system = "x86_64-linux";

    pkgsUnstable = import inputs.unstable {
      inherit system;
      config.allowUnfree = true;
    };

    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;

      overlays = [
        (_final: _prev: {
          inherit (inputs.llm-agents.packages.${system}) pi;
          snappy-switcher = inputs.snappy-switcher.packages.${system}.default;
        })
      ];
    };

    mkHost = user: host:
      inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          inputs.disko.nixosModules.disko
          {_module.args = args // {inherit pkgsUnstable;};}
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
                  inputs.catppuccin.homeModules.catppuccin
                  inputs.plasma-manager.homeModules.plasma-manager
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
      coolding = mkHost "quidome" "coolding";
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
