{
  desktopUser,
  pkgs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./system-vars.nix
    ./vars.nix
    ./hardware-configuration.nix
  ];

  boot.kernelParams = ["consoleblank=60"];

  hardware = {
    cpu.intel.updateMicrocode = true;
    graphics.enable = true;
    graphics.extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  networking.hostName = "nimbus";

  environment.systemPackages = with pkgs; [
    # multimedia
    krita
    digikam

    calibre
    gimp

    ifuse
    virt-manager
  ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  users.users.${desktopUser}.extraGroups = ["wireshark"];

  services = {
    fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };

    usbmuxd.enable = true;
  };

  system.stateVersion = "26.05";
}
