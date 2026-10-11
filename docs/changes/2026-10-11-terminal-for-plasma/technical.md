# Technical spec: Terminal for Plasma

**Status**: done
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
  keyboard shortcut (Meta+Enter only), which the operator sets in the Plasma settings, as a
  written hand step.
- **Terminal key (operator, during Design)**: Mod+Enter opens the terminal, in niri and in Plasma
  (Meta+Enter); in niri it replaces Mod+T.
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
- **Goal**: Ghostty replaces Alacritty in niri, checked in a real niri session before Close.
- **Changes** (3a, first):
  - `modules/home/desktop/niri/default.nix`: `alacritty.enable = lib.mkDefault true;` becomes
    `ghostty.enable = lib.mkDefault true;`; the waybar network `on-click` runs
    `${lib.getExe config.programs.ghostty.package} -e ${lib.getExe' pkgs.networkmanager "nmtui"}`.
  - `modules/home/desktop/niri/config.kdl`: the `Mod+T` line becomes
    `Mod+Return hotkey-overlay-title="Open a Terminal: ghostty" { spawn "ghostty"; }` (Mod+T goes;
    Mod+Return is not bound now).
- **Check** (before 3b): on `truce` (the test laptop), a temporary, uncommitted
  `settings.gui = "niri"` in `hosts/truce/shared.nix`, then a switch (operator approval). The
  operator checks in niri: Mod+Enter opens Ghostty, Mod+T opens nothing, with no title bar from
  niri; the network click opens
  `nmtui` in Ghostty; the colours follow the repository's light/dark setting. Then `truce` goes back
  to Plasma (revert, switch).
  - Passes: go on with 3b.
  - Fails: revert 3a; Alacritty stays in niri; write it under Deviations.
- **Changes** (3b, only after the check passes):
  - `modules/home/theme/default.nix`: remove the `alacritty.settings.colors` block.
  - `modules/home/theme/palette.nix`: remove `black`, `brightBlack`, `white`, `brightWhite` and their
    comment (only the Alacritty block used them).
- **Tests**: `just verify` after 3a and after 3b (the niri build validates `config.kdl`); `just build`
  for `truce` with the temporary niri setting, before the switch.

### Step 4: Product document
- **Goal**: the terminal and its hand step are written down.
- **Changes**: new `docs/product/terminal.md` (product template): purpose; behaviour (Ghostty in
  Plasma and niri, Zellij inside, Konsole as fallback; the copy through the terminal and that it
  does not work in Konsole); errors and limits (light/dark follows the desktop; kitty images not
  inside Zellij; single instance: a crash closes all windows, settings apply to open windows after
  the service restarts); interface: the settings, and the **hand step after a rebuild** – in Plasma
  settings, set the default terminal application to Ghostty, and give Ghostty the keyboard
  shortcut Meta+Enter (the only terminal shortcut the operator uses; Ctrl+Alt+T is left as Plasma
  sets it).
- **Tests**: `just verify` (the leak guard reads the document); the engineer checks each Story 3
  criterion that concerns documentation.

### Step 5: Ghostty on `truce` after the rebuild
- **Goal**: the oldest host runs the managed Ghostty.
- **Changes**: none in the repository.
- **Tests**: `just switch truce` (operator approval) or a switch on the host, back on Plasma after
  the niri check; Ghostty starts from the launcher, opens Zellij, and is not slow. If it fails: back
  to Discover with kitty.

## Decisions
| Decision | Reason | Decision record? |
|----------|--------|------------------|
| Ghostty is enabled in `plasma.nix` and in the niri module, configured in `programs/ghostty.nix` | The existing pattern: program modules configure, desktop modules enable | no |
| Only non-default Ghostty settings; built-in Catppuccin themes | Small config; the same flavours as Zellij; no palette code for Ghostty | no |
| The default terminal and its shortcut are a hand step | Plasma writes `kdeglobals` and `kglobalshortcutsrc` itself; a managed file would break the Plasma settings. Decided with the operator; the functional spec was changed | no – in `docs/product/terminal.md` |
| Mod+Enter opens the terminal: in niri (replaces Mod+T, in the repository) and Meta+Enter in Plasma (hand step, the only terminal shortcut) | Operator's choice during Design; the functional spec names no key | no |
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
- In niri, Alacritty is removed; Mod+Enter (was Mod+T) and the network click open Ghostty.
- Without the `wl-copy` workaround, the Zellij copy does not work in Konsole (accepted).
- Ghostty uses the GPU; `truce` is checked first (Step 0) and last (Step 5).

## Progress
- [ ] Step 0 – skipped: `truce` has no Nix now (see Deviations)
- [x] Step 1
- [x] Step 2
- [ ] Step 3 – 3a done; niri check and 3b wait for a host (see Deviations)
- [x] Step 4
- [ ] Step 5 – skipped: `truce` has no Nix now (see Deviations)
- [x] All checks pass

Results (2026-10-11):
- Step 1: `just verify` passes; `just build` passes for `nimbus`, `bea`, `truce`;
  `programs.ghostty.enable` is `true` on `nimbus`; `ghostty +validate-config` on the generated file
  reports nothing (and fails on a wrong value, checked). The import is placed before `./git.nix`
  (alphabetical order), not after it as Step 1 says. After the operator's switch of `nimbus`:
  true-colour gradient smooth, OSC 8 link opens, kitty image shows outside **and inside** Zellij
  (the spec assumed Zellij does not pass kitty images on – it does), Shift+Enter adds a new line in
  Claude Code inside Zellij, no flicker, window shows only the Plasma title bar (no scroll bar, tab
  bar, menu or extra buttons; `gtk-titlebar` not needed), light/dark follows Plasma while open,
  Konsole still starts.
- Step 2: in Ghostty, Zellij with a test configuration without `copy_command` copied through the
  terminal (OSC 52) to the Plasma clipboard. `copy_command = "wl-copy"` removed; `just verify` and
  `just build nimbus` pass; the generated Zellij config has no `copy_command`. After the operator's
  switch, the copy works with the normal configuration.
- Step 3a: Ghostty enabled in niri instead of Alacritty; the waybar network click runs
  `ghostty -e nmtui`; `Mod+Return` replaces `Mod+T` in `config.kdl` (no other `Mod+Return` bind).
  `just verify` passes. A temporary `gui = "niri"` on `truce` (reverted at once, not committed)
  builds with `just build truce`, so `config.kdl` validates. The niri check in a real session and
  Step 3b wait for a host.
- Step 4: `docs/product/terminal.md` written (purpose, behaviour, limits including the Konsole copy,
  the single process and the open checks, settings, and the Plasma hand step: default terminal
  Ghostty, Meta+Enter as the only terminal shortcut). `just verify` passes (the leak guard reads it).
- After the reviews: `shell-integration-features = "ssh-env,ssh-terminfo"` added (R1); `terminal.md`
  updated (R2, R3); the operator did the Plasma hand step on `nimbus` and it works (A5).
  `just verify` passes.
- Open at Close (known gaps): Ghostty on `truce` (Steps 0 and 5); the niri check in a real session
  and Step 3b (Alacritty colours).

## Deviations
- **Stricter reading of Story 4**: the spec makes niri a bonus ("if it works well"); the operator
  asked during Design to replace Alacritty in niri as a fixed step. The niri check runs on `truce`
  before Close (Step 3); if Ghostty does not work well in niri, Step 3 is reverted and Alacritty
  stays.
- **`truce` not available (Implement, 2026-10-11)**: `truce` has no Nix installed now. Step 0
  and Step 5 are skipped; the Story 3 criterion "starts and is not slow on `truce`" stays open
  until `truce` runs this configuration. `just build truce` still runs. The niri check (Step 3)
  waits for `truce` or another host (operator's choice): Step 3a goes in, Step 3b (removing the
  Alacritty colours) waits for the check. The change may close with both checks open, written down
  as known gaps.
- No other difference from `functional.md`. The hand step for the default terminal is in the
  functional spec itself (changed with the operator during Design).

### Spec review of the deviations
Reviewed 2026-10-11 by `/review spec … deviations` (fresh agent). Judged: the Story 4 deviation
above, and the change to Story 3 made during Design after the spec review (default terminal as a
hand step), which the second bullet points to. Read: `functional.md` (and its uncommitted diff),
`idea.md`, `change.md`, `docs/vision.md`, `docs/language.md`, Step 3 and Step 4 of this document
for what the deviations mean in practice.

| Deviation | What the user is doing here | Verdict | Note |
|---|---|---|---|
| Story 4: Ghostty replaces Alacritty in niri as a fixed step | Opening a terminal in the playground session, with the same terminal as in Plasma | serves – note | Niri is the playground, so a rough edge never blocks (vision principle). But the spec's condition "if it works well in niri" now moves to after the replacement, and Step 3 checks niri only "when a niri session is used" – no moment is set, so the revert to Alacritty may never be triggered. Step 3 also deletes the Alacritty colour block and four palette colours, so a revert means rebuilding them from git; the vision principle "do not remove a working experiment" leans against deleting what may be needed again. Suggest: set when the niri check happens (before Close, on one host), or keep the Alacritty colours until it passes. Checked: read Step 3; search `alacritty` in `modules/` (`niri/default.nix` lines 70 and 111, `niri/config.kdl` 365, `theme/default.nix` 85). |
| Story 3: default terminal and its shortcut set by hand after a rebuild (functional spec changed during Design) | Pressing the terminal shortcut or "Open terminal" in the file manager right after a rebuild, and getting the terminal that has the features | serves – note | The operator decided it and the step is written down (Step 4), so it is not forgotten. But it conflicts with the letter of core value 3 and the north star: after a rebuild only the identity steps remain, and in `language.md` the default terminal is not an identity step. The vision lists one known gap (host secrets); this is a second one, and the vision's "Where we are" should say so at Close, or the vision is no longer true. Until the hand step is done, the quickest way to a terminal opens Konsole, which lacks the features – a small, visible cost after each reinstall. The reason given ("Plasma writes these settings itself") rules out managing the user's own file, but not a system-wide default that Plasma reads under the user's file (for example `kdeglobals` in the system XDG config folder) – not checked whether that works for the default terminal or the shortcut; Design may want to try it before accepting the gap. Checked: search `programs.plasma`, `kdeglobals`, `TerminalApplication`, `shortcuts` in `modules/` and `hosts/` (no Plasma settings are managed; `kdeglobals` is written only in `theme/default.nix`); system-wide default not checked. |

Decided with the operator, 2026-10-11:
- Story 4 note: the niri check runs on `truce` before Close; the Alacritty colours are removed only
  after it passes (Step 3a / check / 3b).
- Story 3 note: the hand step stays. For `/close`: name the default terminal as a second known gap
  next to host secrets in `vision.md` ("Where we are"). The system-wide default is a line in
  `docs/ideas.md`, not part of this change.

No deviation conflicts with the vision outright; the Story 3 change needs the vision's known gaps
updated at Close (a task for `/close`). The approved spec was changed after its review; this table
is the review of that change.

## Review findings
Reviewed 2026-10-11 by `/review build` (fresh agent). Read: the diff against `main` (uncommitted
work: `ghostty.nix`, `plasma.nix`, `niri/default.nix`, `niri/config.kdl`, `zellij/default.nix`,
`programs/default.nix`, `docs/product/terminal.md`), the change folder, `docs/architecture.md`,
decision records 0001 and 0002, `AGENTS.md`. No extra text was passed in the arguments.

- **R1 – SSH from Ghostty to a host without its terminfo (bug against Story 2's intent).** Ghostty
  sets `TERM=xterm-ghostty`. Its terminfo is only in the operator's own profile, not system-wide,
  and Ghostty's SSH help is off by default. So `ssh root@<host>` (used by `just gc`), SSH into the
  live install image, a `gui = "none"` host or a server from the other repository gets a `TERM` the
  remote does not know: shells, `nmtui`, editors and Zellij there may draw wrong or refuse to start.
  Story 2 counts "Zellij over SSH" as a gain of this change, and the product document does not name
  the limit. Options: `shell-integration-features = ssh-env,ssh-terminfo` in `ghostty.nix` (Ghostty
  then installs its terminfo on the remote or falls back to `xterm-256color`), or only `ssh-env`;
  and/or the Ghostty terminfo in the system packages and the live images. Checked: `ls` of
  `/run/current-system/sw/share/terminfo/x/` (no `xterm-ghostty`) and
  `/etc/profiles/per-user/*/share/terminfo/x/` (has it) on `nimbus`; `nix eval` of
  `environment.enableAllTerminfo` for `nimbus` (`false`); `ghostty +show-config --default --docs`
  (`shell-integration-features = …,no-ssh-env,no-ssh-terminfo,…`). Not run over a real SSH session.
  - Fixed 2026-10-11: inside Zellij `TERM` is `xterm-256color` (operator checked), so only windows without Zellij use `xterm-ghostty`. Added `shell-integration-features = "ssh-env,ssh-terminfo"` to `ghostty.nix`; `+show-config` shows the other features stay on (cursor, title, path); `+validate-config` passes. Written in `terminal.md`.
- **R2 – Zellij does not follow Plasma's light/dark mode; the product document says it matches.**
  Ghostty switches Latte/Mocha with Plasma's mode; Zellij's theme comes from `settings.theme`
  (default `dark`), which Plasma does not change. With Plasma in light mode, the Zellij bar stays
  Mocha on a Latte terminal. Changing Zellij is out of scope, but `docs/product/terminal.md` ("the
  same as Zellij") and the comment in `ghostty.nix` ("same flavors as Zellij") are only true when
  both happen to agree. Write it as a limit (or say "the same flavours"), and maybe an idea line.
  Checked: trace `modules/home/programs/zellij/default.nix` (`zellijTheme` from `settings.theme`),
  `modules/home/settings.nix` (default `dark`), `nix eval` of the Zellij settings for `nimbus`
  (`theme = "catppuccin-mocha"`). Not seen on screen.
  - Fixed 2026-10-11 in the documents: `terminal.md` says "the same flavours as Zellij" and names the light/dark mismatch as a limit. Not fixed in code: Story 3 asks only the terminal to follow Plasma; idea line added in `docs/ideas.md`.
- **R3 – `desktop-reset kde` undoes the hand step.** It moves `.config/kdeglobals` and
  `.config/kglobalshortcutsrc` aside, which hold the default terminal and the Meta+Enter shortcut.
  `docs/product/terminal.md` names the hand step only "after a rebuild". Add "and after
  `desktop-reset kde`". Checked: read `paths_for kde` in `modules/home/desktop/desktop-reset.sh`.
  - Fixed 2026-10-11: `terminal.md` says to do the hand step again after `desktop-reset kde`.
- **R4 – Claims about checks.** True: `nix flake check` passes (alejandra, statix, deadnix, leak
  guard; all hosts evaluate); `statix check`, `deadnix`, `alejandra --check` clean;
  `ghostty +validate-config` on the generated file exits 0, and exits 1 on `scrollbar = bogus`, so
  the test can fail; home-manager defaults `systemd.enable`, `enableZshIntegration` are `true` and
  the package is 1.3.1. Checked: run. Not checked: `just build` per host (the flake check only
  evaluates), the temporary niri build on `truce` (needs a repository edit), and the hand checks on
  `nimbus` (operator observations). Note: `niri validate` checks syntax only, not that `ghostty` is
  on the path, so the 3a build does not prove Mod+Return opens Ghostty; the open niri check is
  rightly kept.
  - Not fixed 2026-10-11: the hand checks and builds are recorded under Progress; the real niri session stays an open check (see Deviations).
- **R5 – Siblings, checked and fine.** `ghostty -e nmtui` from waybar has CLI arguments, so with
  `gtk-single-instance = detect` it runs as its own process with niri's environment, not through
  the service (read from `+show-config --default --docs`). No `alacritty.enable` is left anywhere;
  the remaining `alacritty.settings.colors` block writes nothing while Alacritty is off, as the
  deviation intends (search `alacritty` in `modules`, `hosts`). Enabling Ghostty in `plasma.nix`
  and the niri module follows the niri precedent (Alacritty, fuzzel enabled there) and the
  "program modules configure, desktops enable" pattern. `wl-clipboard` stays in the graphical base;
  README's line about it is still true (search `wl-clipboard`).
  - No action 2026-10-11: all fine.
- **R6 – Change documents for `/close`.** The functional spec says Zellij probably does not pass
  kitty images on; the trial shows it does (Progress, Step 1) – the product document already says
  so. The import order (before `./git.nix`) differs from Step 1 and is recorded under Progress, not
  under Deviations; harmless, as Step 1 was wrong about alphabetical order. The `vision.md` known
  gap (default terminal as hand step) is still a `/close` task.
  - For `/close` 2026-10-11: images in Zellij, import order, and the vision gap are handled at Close.

Verdict: no blocker in the code. R1 should be settled before Close (a setting or a written
limit); R2 and R3 are doc fixes.

Reviewed 2026-10-11 by `/review accept` (fresh agent). Read: `change.md`, `idea.md`,
`functional.md`, the diff against `main` (uncommitted), `docs/product/terminal.md`; looked at the
running system on `nimbus` read-only. View formed before reading Deviations and the R findings. No
extra text was passed in the arguments.

- **A1 – Story 2, modern features: faithful.** Shift+Enter, OSC 52 copy, no flicker, kitty image,
  OSC 8, true colour all pass on `nimbus` per the operator's observations (Progress, Step 1–2); the
  `wl-copy` workaround is gone, as the spec asks when the copy passes. Kitty images work also
  inside Zellij – better than the spec assumed. The Konsole copy loss is the accepted trade-off.
  Checked: diff of `zellij/default.nix`; `~/.config/ghostty/config` is the generated store file
  with the four settings; hand checks themselves not repeated (operator observations).
  For `/close`: the Story 2 and 3 boxes in `functional.md` are still unticked.
  - No action 2026-10-11: faithful.
- **A2 – Story 2, "also works in Zellij over SSH": neutral drift.** The spec names this as the gain
  of removing the workaround; nothing checks it, and R1 (no `xterm-ghostty` terminfo on remote
  hosts, root or servers) can break the remote side. Settle R1 or write the limit in the product
  document. Checked: not run over SSH; `echo $TERM` in this session is `xterm-256color`.
  - Fixed 2026-10-11 with R1. Zellij copy over SSH is not tested by hand; it is not an acceptance criterion.
- **A3 – Story 3, `truce` starts Ghostty and is not slow: neutral drift (open criterion).** This is
  the pass/fail check that sends the change back to Discover with kitty; it is not done because
  `truce` has no Nix now (Deviations). The daily desktop stays safe (Konsole), and the product
  document names it under "Not yet checked". Acceptable only as a written known gap; when `truce`
  returns, a failure there still reopens the terminal choice. Checked: read Deviations and
  `docs/product/terminal.md`.
  - Not fixed 2026-10-11: `truce` has no Nix now; stays an open check and a known gap at Close.
- **A4 – Story 3, light/dark: faithful for the terminal, neutral drift for what runs in it.**
  Ghostty follows Plasma's mode, as decided. But Zellij, helix, git and the shell prompt pick their
  colours from `settings.theme` (default `dark`), so with Plasma in light mode the operator sees
  Mocha bars and tools on a Latte terminal – not the "one calm, consistent desktop" the story is
  for. The spec decided the terminal side only; the result should at least say so (same as R2),
  and an idea line for following the mode in the tools is worth it. Checked: search
  `settings.theme` in `modules/home` (base, git, helix, neovim, zed, zellij).
  - Fixed 2026-10-11 in the documents, see R2.
- **A5 – Story 3, default terminal and Meta+Enter: faithful adaptation, not yet observed.** The hand
  step is written down as the spec asks. On `nimbus` it has not been done yet: no
  `TerminalApplication` in `~/.config/kdeglobals`, no Ghostty entry in `~/.config/kglobalshortcutsrc`.
  So the criterion "Plasma opens the new terminal by default" has not been seen working, and
  whether the written steps give that result (Dolphin "Open terminal", Meta+Enter free in Plasma)
  is not checked. Do the hand step once on `nimbus` before Close, following the document word for
  word; add R3 (`desktop-reset kde`). Checked: grep of both files.
  - Fixed 2026-10-11: the operator did the hand step on `nimbus` as `terminal.md` says; Meta+Enter and "Open terminal" in Dolphin open Ghostty. R3 added to the document.
- **A6 – Story 3, window, font, launcher, Konsole: faithful.** `window-decoration = server`,
  `scrollbar = never`, tab bar `auto` (none with one tab); operator saw only the Plasma title bar.
  Launcher entry `com.mitchellh.ghostty.desktop` is in the user profile; `konsole` is still on the
  system path. Font is `JetBrainsMono Nerd Font` at Ghostty's default 12 (operator's choice; the
  niri theme uses size 10 for KDE apps – a small difference, chosen). Checked: `ls` of the profile
  applications, `which konsole`, `ghostty +show-config --default`.
  - No action 2026-10-11: faithful.
- **A7 – Story 4, niri: neutral drift (recorded deviation).** Ghostty replaces Alacritty in niri
  before the "works well" check; the check is open. Alacritty is no longer installed in niri and
  Mod+T is gone, so if Ghostty fails there, niri has no terminal key until the revert – acceptable
  for the playground, and the Alacritty colours are kept for the revert. Checked: diff of
  `niri/default.nix`, `config.kdl`; whether niri has any other terminal installed not checked.
  - Not fixed 2026-10-11: accepted by the operator (playground); the niri check stays open.
- **A8 – single instance: neutral drift.** Keeping home-manager's Ghostty user service means one
  crash closes every terminal window – a new way to lose all daily work at once that Konsole did
  not have. Documented in the product document; the operator should know it is a choice, not a
  must (`systemd.enable = false` removes it at the cost of slower new windows). Checked: read
  Decisions and `systemctl --user status app-com.mitchellh.ghostty.service` (running).
  - Not fixed 2026-10-11: the operator keeps the single service (faster new windows); documented in `terminal.md`.

Verdict: **accepted with notes.** What was built is what was meant for Stories 1, 2 and the visible
parts of 3. Before Close: do and observe the Plasma hand step (A5); fix the product document for
R2/A4 and R3; settle R1/A2; record the `truce` (A3) and niri (A7) checks as known gaps if they are
still open; tick the passed boxes in `functional.md`.
