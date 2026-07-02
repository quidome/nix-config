{lib}: let
  lua = lib.generators.mkLuaInline;

  mk = keyExpr: callExpr: opts: {
    _args =
      [
        (lua keyExpr)
        (lua callExpr)
      ]
      ++ (
        if opts == null
        then []
        else [opts]
      );
  };

  workspaceBinds = builtins.concatLists (builtins.genList (
      i: let
        ws = toString (i + 1);
      in [
        (mk "mod .. \" + ${ws}\"" ''hl.dsp.focus({ workspace = ${ws} })'' null)
        (mk "mod .. \" + SHIFT + ${ws}\"" ''hl.dsp.window.move({ workspace = ${ws} })'' null)
      ]
    )
    9);
in
  [
    (mk "mod .. \" + SPACE\"" "hl.dsp.exec_cmd(launcher .. \" fuzzel\")" null)

    (mk "mod .. \" + RETURN\"" "hl.dsp.exec_cmd(launcher .. \" \" .. terminal)" null)
    (mk "mod .. \" + E\"" "hl.dsp.exec_cmd(launcher .. \" thunar\")" null)

    (mk "mod .. \" + P\"" "hl.dsp.window.pseudo()" null)
    (mk "mod .. \" + J\"" "hl.dsp.layout(\"togglesplit\")" null)

    (mk "mod .. \" + R\"" "hl.dsp.exec_cmd(\"hyprctl reload\")" null)
    (mk "mod .. \" + L\"" "hl.dsp.exec_cmd(\"hyprlock\")" null)
    (mk "mod .. \" + V\"" "hl.dsp.window.float({ action = \"toggle\" })" null)
    (mk "mod .. \" + F\"" "hl.dsp.window.fullscreen()" null)
    (mk "mod .. \" + SHIFT + C\"" "hl.dsp.exit()" null)
    (mk "mod .. \" + SHIFT + Q\"" "hl.dsp.window.kill()" null)

    (mk "mod .. \" + LEFT\"" "hl.dsp.focus({ direction = \"left\" })" null)
    (mk "mod .. \" + RIGHT\"" "hl.dsp.focus({ direction = \"right\" })" null)
    (mk "mod .. \" + UP\"" "hl.dsp.focus({ direction = \"up\" })" null)
    (mk "mod .. \" + DOWN\"" "hl.dsp.focus({ direction = \"down\" })" null)

    (mk "mod .. \" + CTRL + LEFT\"" "hl.dsp.focus({ workspace = \"r-1\" })" null)
    (mk "mod .. \" + CTRL + RIGHT\"" "hl.dsp.focus({ workspace = \"r+1\" })" null)
    (mk "mod .. \" + SHIFT + CTRL + LEFT\"" "hl.dsp.window.move({ workspace = \"r-1\" })" null)
    (mk "mod .. \" + SHIFT + CTRL + RIGHT\"" "hl.dsp.window.move({ workspace = \"r+1\" })" null)

    (mk "mod .. \" + S\"" "hl.dsp.workspace.toggle_special(\"magic\")" null)
    (mk "mod .. \" + SHIFT + S\"" "hl.dsp.window.move({ workspace = \"special:magic\" })" null)

    (mk "\"PRINT\"" "hl.dsp.exec_cmd(\"grimblast copysave area\")" null)
    (mk "\"SHIFT + PRINT\"" "hl.dsp.exec_cmd(\"grimblast copysave active\")" null)
    (mk "\"SHIFT + CTRL + PRINT\"" "hl.dsp.exec_cmd(\"grimblast copysave output\")" null)

    (mk "\"XF86AudioPlay\"" "hl.dsp.exec_cmd(\"playerctl play-pause\")" {locked = true;})
    (mk "\"XF86AudioMute\"" "hl.dsp.exec_cmd(\"volumectl toggle-mute\")" {locked = true;})
    (mk "\"XF86AudioRaiseVolume\"" "hl.dsp.exec_cmd(\"volumectl -u up\")" {
      locked = true;
      repeating = true;
    })
    (mk "\"XF86AudioLowerVolume\"" "hl.dsp.exec_cmd(\"volumectl -u down\")" {
      locked = true;
      repeating = true;
    })
    (mk "\"XF86MonBrightnessDown\"" "hl.dsp.exec_cmd(\"lightctl down\")" {
      locked = true;
      repeating = true;
    })
    (mk "\"XF86MonBrightnessUp\"" "hl.dsp.exec_cmd(\"lightctl up\")" {
      locked = true;
      repeating = true;
    })

    (mk "\"SUPER + mouse:272\"" "hl.dsp.window.drag()" {mouse = true;})
    (mk "\"SUPER + mouse:273\"" "hl.dsp.window.resize()" {mouse = true;})
  ]
  ++ workspaceBinds
