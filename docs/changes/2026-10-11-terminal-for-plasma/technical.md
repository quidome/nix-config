# Technical spec: Terminal for Plasma

**Status**: draft
**Size**: story
**Change**: docs/changes/2026-10-11-terminal-for-plasma/
**Date**: 2026-10-11

## Objective
Make Ghostty the terminal on every Plasma host and in niri, set up so that it looks like a normal
window of the graphical session, follows its light/dark mode, and lets Zellij copy through the
terminal (OSC 52) again.

## Requirements summary
From `functional.md` (approved 2026-10-11; Story 3 changed with the operator during Design):

- **Choice made in Discover**: Ghostty (1.3.1 in the stable channel). If Ghostty fails Shift+Enter
  in Claude Code or does not run on `truce`, the change goes back to Discover with kitty as the next
  candidate. Konsole stays installed as the fallback.
- **Story 2 – modern features, inside Zellij**: Shift+Enter adds a new line in Claude Code; a kitty
  image shows (outside Zellij is enough); an OSC 8 link opens on click; true colour is smooth; no
  flicker while Claude Code redraws. Text copied in Zellij through the terminal (OSC 52, without the
  `wl-copy` workaround) can be pasted in another app; if so, the workaround is removed. Accepted:
  the Zellij copy then no longer works in Konsole.
- **Story 3 – at home in Plasma**: on every Plasma host, in the launcher; only the Plasma title bar
  (no own header bar, extra buttons, scroll bar, menu, toolbar or tab bar); the monospace font of
  the setup (`JetBrainsMono Nerd Font`, size 12 – Ghostty's default, chosen by the operator); a
  light and a dark theme that follow Plasma's mode, also while open; starts and is not slow on
  `truce`; all after a rebuild with no setting by hand – except the default terminal and its
  keyboard shortcut, which the operator sets in the Plasma settings, as a written hand step.
- **Story 4 – niri**: Ghostty replaces Alacritty in niri (read more strictly, see Deviations).

## Current state
- `modules/home/programs/`: one module per program; each configures under
  `lib.mkIf config.programs.<name>.enable` and does not enable (pattern in `docs/architecture.md`).
  `default.nix` imports them in alphabetical order.
- `modules/home/desktop/plasma.nix`: `lib.mkIf (config.settings.gui == "plasma")`; sets one session
  variable now. Konsole comes with Plasma (`services.desktopManager.plasma6`).
- `modules/home/desktop/niri/default.nix`: `programs.alacritty.enable = lib.mkDefault true` (line
  70, "Terminal and launcher used by the key bindings in config.kdl"); the waybar network module
  runs `alacritty -e nmtui` on click (line 111).
- `modules/home/desktop/niri/config.kdl:365`: `Mod+T` spawns `alacritty`.
- `modules/home/theme/default.nix:85`: Catppuccin colours for Alacritty (niri only). The palette
  entries `black`, `brightBlack`, `white`, `brightWhite` in `modules/home/theme/palette.nix` exist
  only for this block.
- `modules/home/programs/zellij/default.nix:32`: `copy_command = "wl-copy";` (the workaround).
  Zellij uses Catppuccin Latte / Mocha.
- `nerd-fonts.jetbrains-mono` is installed on every graphical host
  (`modules/system/profiles/graphical.nix`).
- home-manager `programs.ghostty`: `settings` writes `~/.config/ghostty/config`; defaults in this
  repository: `systemd.enable = true` (one user service, single instance),
  `enableZshIntegration = true`, package `pkgs.ghostty` 1.3.1.
- Ghostty 1.3.1 options (checked with `ghostty +show-config --default --docs`):
  `window-decoration = auto|client|server|none`, `scrollbar = system|never`,
  `window-show-tab-bar = auto` (default; no tab bar with one tab), `theme = light:…,dark:…`
  (follows the desktop), `font-size = 12` (default). Built-in themes include `Catppuccin Latte` and
  `Catppuccin Mocha`.

## Steps

### Step 0: Ghostty starts on `truce` (risk first)
- **Goal**: find out early whether the oldest host can run Ghostty.
- **Changes**: none. The operator runs, on `truce` in Plasma:
  `nix shell .#nixosConfigurations.truce.pkgs.ghostty -c ghostty`.
- **Tests**: Ghostty opens and does not feel slow (typing, scrolling a long output). If it fails:
  stop; the change goes back to Discover with kitty. Skip this step if the operator already knows
  the result.

### Step 1: Ghostty in Plasma
- **Goal**: Ghostty on every Plasma host, set up as Story 3 asks.
- **Changes**:
  - New `modules/home/programs/ghostty.nix`:
    ```nix
    {
      config,
      lib,
      ...
    }: {
      config = lib.mkIf config.programs.ghostty.enable {
        programs.ghostty.settings = {
          font-family = "JetBrainsMono Nerd Font";
          theme = "light:Catppuccin Latte,dark:Catppuccin Mocha";
          window-decoration = "server";
          scrollbar = "never";
        };
      };
    }
    ```
    Only values that differ from Ghostty's defaults.
  - `modules/home/programs/default.nix`: import `./ghostty.nix` after `./git.nix`.
  - `modules/home/desktop/plasma.nix`: inside the existing `lib.mkIf`, add
    `programs.ghostty.enable = lib.mkDefault true;`.
- **Tests**:
  - `just verify`; `just build` for `nimbus`, `bea`, `truce`.
  - `nix eval` of `programs.ghostty.enable` for `nimbus` is `true`.
  - `ghostty +validate-config` on the generated config file reports nothing.
  - After `just switch nimbus` (operator approval), hand checks with a check script in a temporary
    folder outside the repository (true-colour gradient, OSC 8 link, kitty image via `kitten icat`
    outside Zellij with `ghostty --gtk-single-instance=false`), and by hand: Shift+Enter in Claude
    Code inside Zellij; no flicker while Claude Code works; only the Plasma title bar, no scroll bar,
    tab bar or extra buttons; change Plasma's light/dark mode while Ghostty is open; Konsole still
    starts.
  - If `window-decoration = server` still shows Ghostty's own header bar: add
    `gtk-titlebar = false`, write it under Deviations, check again.
  - If Shift+Enter fails: stop; back to Discover with kitty.

### Step 2: Zellij copy through the terminal
- **Goal**: Zellij copies through the terminal (OSC 52) when Ghostty supports it.
- **Changes**: if the test passes, remove `copy_command = "wl-copy";` from
  `modules/home/programs/zellij/default.nix`. If it fails, no change.
- **Tests**:
  - Before the change: in Ghostty, start Zellij with a temporary copy of
    `~/.config/zellij/config.kdl` without the `copy_command` line (`ZELLIJ_CONFIG_FILE=…`), copy text
    in Zellij, paste in another app.
  - After the change, `just verify`, `just build nimbus`, switch (operator approval), and the copy
    test again with the normal configuration.
  - The result (passed and removed, or failed and kept) goes under Progress.

### Step 3: Ghostty in niri
- **Goal**: Ghostty replaces Alacritty in niri.
- **Changes**:
  - `modules/home/desktop/niri/default.nix`: `alacritty.enable = lib.mkDefault true;` becomes
    `ghostty.enable = lib.mkDefault true;`; the waybar network `on-click` runs
    `${lib.getExe config.programs.ghostty.package} -e ${lib.getExe' pkgs.networkmanager "nmtui"}`.
  - `modules/home/desktop/niri/config.kdl`: `Mod+T hotkey-overlay-title="Open a Terminal: ghostty"
    { spawn "ghostty"; }`.
  - `modules/home/theme/default.nix`: remove the `alacritty.settings.colors` block.
  - `modules/home/theme/palette.nix`: remove `black`, `brightBlack`, `white`, `brightWhite` and their
    comment (only the Alacritty block used them).
- **Tests**:
  - `just verify` (the niri build validates `config.kdl`).
  - A temporary, uncommitted `settings.gui = "niri"` on one host, then `just build` for it; revert.
  - Operator check in niri (when a niri session is used): Mod+T opens Ghostty, with no title bar
    from niri; the network click opens `nmtui` in Ghostty; the colours follow the repository's
    light/dark setting.

### Step 4: Product document
- **Goal**: the terminal and its hand step are written down.
- **Changes**: new `docs/product/terminal.md` (product template): purpose; behaviour (Ghostty in
  Plasma and niri, Zellij inside, Konsole as fallback; the copy through the terminal and that it
  does not work in Konsole); errors and limits (light/dark follows the desktop; kitty images not
  inside Zellij; single instance: a crash closes all windows, settings apply to open windows after
  the service restarts); interface: the settings, and the **hand step after a rebuild** – in Plasma
  settings, set the default terminal application to Ghostty and the "launch terminal" keyboard
  shortcut (Ctrl+Alt+T) to Ghostty.
- **Tests**: `just verify` (the leak guard reads the document); the engineer checks each Story 3
  criterion that concerns documentation.

### Step 5: Ghostty on `truce` after the rebuild
- **Goal**: the oldest host runs the managed Ghostty.
- **Changes**: none in the repository.
- **Tests**: `just switch truce` (operator approval) or a switch on the host; Ghostty starts from the
  launcher, opens Zellij, and is not slow. If it fails: back to Discover with kitty.

## Decisions
| Decision | Reason | Decision record? |
|----------|--------|------------------|
| Ghostty is enabled in `plasma.nix` and in the niri module, configured in `programs/ghostty.nix` | The existing pattern: program modules configure, desktop modules enable | no |
| Only non-default Ghostty settings; built-in Catppuccin themes | Small config; the same flavours as Zellij; no palette code for Ghostty | no |
| The default terminal and its shortcut are a hand step | Plasma writes `kdeglobals` and `kglobalshortcutsrc` itself; a managed file would break the Plasma settings. Decided with the operator; the functional spec was changed | no – in `docs/product/terminal.md` |
| Keep home-manager's `systemd.enable = true` for Ghostty | Faster new windows; the downsides are documented | no |
| `window-decoration = server`, no `gtk-titlebar` unless needed | Plasma draws the title bar; add a setting only when a check shows it is needed | no |

## Not in scope
- Setting the default terminal or keyboard shortcuts from the repository.
- Removing Konsole or changing its settings.
- Other Zellij changes than removing `copy_command`.
- A Ghostty colour palette from the repository's theme module.
- macOS.

## Test plan
- **Existing tests that must still pass**: `just verify` (alejandra, statix, deadnix, flake check,
  leak guard); `just build` for `nimbus`, `bea`, `truce`.
- **New tests**: `ghostty +validate-config` (Step 1); the hand checks of Stories 2 and 3 on
  `nimbus` (Steps 1, 2) and `truce` (Steps 0, 5); a temporary niri build (Step 3). Each result is
  recorded under Progress.

## Compatibility and performance
- Plasma hosts get a new program and a user service; Konsole is unchanged.
- In niri, Alacritty is removed; Mod+T and the network click open Ghostty.
- Without the `wl-copy` workaround, the Zellij copy does not work in Konsole (accepted).
- Ghostty uses the GPU; `truce` is checked first (Step 0) and last (Step 5).

## Progress
- [ ] Step 0
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3
- [ ] Step 4
- [ ] Step 5
- [ ] All checks pass

## Deviations
- **Stricter reading of Story 4**: the spec makes niri a bonus ("if it works well"); the operator
  asked during Design to replace Alacritty in niri as a fixed step. If Ghostty turns out not to work
  well in niri, Step 3 is reverted and Alacritty stays.
- No other difference from `functional.md`. The hand step for the default terminal is in the
  functional spec itself (changed with the operator during Design).

## Review findings
