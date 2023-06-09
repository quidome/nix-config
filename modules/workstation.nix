{ config, pkgs, lib, ... }:
with lib;
{
  config = mkIf (config.my.profile = "workstation" ) {
  fonts.fonts = with pkgs;
  [(
  nerdfonts.override {
  fonts = [
    "JetBrainsMono"
    "FiraCode"
    "SourceCodePro"
  ];
})
];
};
}
