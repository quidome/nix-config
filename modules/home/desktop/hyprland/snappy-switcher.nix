{
  lib,
  pkgs,
}: let
  lua = lib.generators.mkLuaInline;
in {
  package = pkgs.snappy-switcher;

  binds = [
    {
      _args = [
        (lua ''"ALT + TAB"'')
        (lua ''hl.dsp.exec_cmd("snappy-switcher next --mod alt")'')
      ];
    }
    {
      _args = [
        (lua ''"SUPER + TAB"'')
        (lua ''hl.dsp.exec_cmd("snappy-switcher next --workspace --mod super")'')
      ];
    }
  ];
}
