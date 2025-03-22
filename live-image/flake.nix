{
  description = "My Nixos install images";
  inputs.nixos.url = "nixpkgs/nixos-24.11";
  outputs = { self, nixos }: {
    nixosConfigurations = {
      baseIso = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./iso/base.nix
        ];
      };
      bcachefs = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
          ./iso/base.nix
          ./iso/bcachefs.nix
          ./scripts
        ];
      };
    };
  };
}
