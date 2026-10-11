# Functional spec: Terminal for Plasma

**Status**: approved
**Change**: docs/changes/2026-10-11-terminal-for-plasma/
**Date**: 2026-10-11

## Context
The operator does most daily work in a terminal: LLM tools such as Claude Code and pi agent, inside
Zellij (a terminal multiplexer). On every host, a new shell starts Zellij automatically, so the
terminal always shows Zellij. Plasma is the daily desktop on all three hosts (`nimbus`, `bea`,
`truce`); niri is the playground and uses Alacritty now.

Konsole, the terminal that comes with Plasma, falls short for this work:
- Shift+Enter (a new line in the Claude Code prompt) does not work as expected.
- A copy in Zellij, sent through the terminal (OSC 52), does not reach the Plasma clipboard. The
  operator works around this: Zellij now copies with `wl-copy` (straight to the clipboard of the
  local host), so the copy works, but only on the local host – not in Zellij over SSH.

The operator wants a **lean** terminal that **works well in Plasma** and has the **modern terminal
features** that these tools use:
- copy to the clipboard through the terminal (OSC 52);
- the extended keyboard protocol (the kitty keyboard protocol), so key combinations such as
  Shift+Enter reach the program;
- synchronized output (screen updates without flicker);
- images in the terminal, in the kitty image format;
- clickable links (OSC 8);
- true colour (24-bit colour).

"Lean" means what the operator sees: only the terminal text and the normal Plasma title bar. A
terminal may have tabs or a multiplexer built in, if they never show and are not in the way.

There is no preferred terminal. The operator chooses from a comparison, with facts that are checked
in practice. The operator also uses Ghostty on macOS; the same terminal everywhere is a gain, not
a requirement. Operator experience on macOS (not yet checked on Linux): in Ghostty with Zellij, the
copy through the terminal works, and Shift+Enter works in Claude Code. On Linux, Ghostty is a
different app (built on GTK), so the trial checks this again.

### Comparison (from documentation, 2026-10-11 – to be checked in practice, see Story 1)

Versions are those in the stable channel that this repository uses.

| Need | Konsole 26.04 | Ghostty 1.3 | kitty 0.49 | WezTerm (development build 2026-03) |
|---|---|---|---|---|
| OSC 52 clipboard | write only (since 2024) | yes | yes | yes |
| Extended keyboard protocol | unclear | yes | yes | yes |
| Synchronized output | unclear | yes | yes | yes |
| Kitty images | yes | yes | yes | yes |
| Clickable links | yes | yes | yes | yes |
| True colour | yes | yes | yes | yes |
| Visible extras by default | menu bar, toolbar, tab bar, scroll bar | own header bar with tab and menu buttons | tab bar with more than one tab | own tab bar, maybe own title buttons |
| Extras can be removed by a setting | yes | yes | yes | yes |
| Title bar in Plasma | Plasma's own | own (GNOME style) by default; Plasma's own with a setting | Plasma's own | own or Plasma's own, by setting |
| Needs a GPU (OpenGL) | no | yes | yes | yes |
| Works in niri (bonus) | yes | yes | yes | yes |

Not in the comparison: Alacritty (no images) and foot (only sixel images, not the kitty format).
Konsole stays in the comparison only if Shift+Enter in Claude Code and the Zellij copy can be made
to work in it (Story 1).

### Trial and choice (2026-10-11, on `nimbus`, Plasma)
| Candidate | Result | Source |
|---|---|---|
| Konsole | **out**: Shift+Enter in Claude Code (inside Zellij) does not add a new line. Stays as the fallback | operator, in daily use |
| WezTerm | **out**: no kitty image shown | trial, outside Zellij |
| kitty | kitty image shown; other needs from documentation. **Next candidate** if Ghostty fails in Story 2 or 3 | trial, outside Zellij |
| Ghostty | kitty image shown. Copy through Zellij and Shift+Enter in Claude Code work on macOS. Other needs from documentation | trial, outside Zellij; operator experience on macOS |

**Choice: Ghostty**, by the operator. Reasons: no known fact against it; the image works on Linux;
copy and Shift+Enter work in the operator's macOS setup; the same terminal as on the operator's
MacBooks. Not yet checked on Linux: Shift+Enter, the copy through Zellij, the window in Plasma, and
`truce`. These are acceptance criteria in Stories 2 and 3.

Note: the image test ran outside Zellij. Zellij probably does not pass kitty images on (not
checked), so images are a need outside Zellij only. The test that put WezTerm out therefore weighs
less than it seems; the choice of Ghostty does not depend on it.

## User stories

### Story 1: Choose with checked facts
**As the** operator, **I want to** try candidates against my needs before I choose, **so that**
the choice rests on how they work in my setup, not on feature lists.

#### Acceptance criteria
- [x] The candidates were tried on a Plasma host where it decides between them (images), and the
  results are in "Trial and choice" above.
- [x] Konsole was checked first for Shift+Enter in Claude Code; it failed, so Konsole is out and
  stays only as the fallback.
- [x] The operator chose one candidate (Ghostty); the choice and the reason are written above.

#### Behaviour
Done in Discover, before this spec was approved. The checks that were not done on Linux are
acceptance criteria in Stories 2 and 3; they are checked on the real setup in Implement.

#### Errors and edge cases
- Ghostty fails Shift+Enter in Claude Code (Story 2), or does not start or is clearly slow on
  `truce` (Story 3): the change goes back to Discover, with kitty as the next candidate.
- The copy through Zellij fails in Ghostty: the `wl-copy` workaround stays (Story 2); this does not
  block the change.
- A feature fails only inside Zellij: the cause (terminal or Zellij) is named, because a Zellij
  problem does not count against the terminal.

### Story 2: The modern features work in my real setup
**As the** operator, **I want** all six modern features to work in the chosen terminal, inside
Zellij, with my tools, **so that** daily work with LLM tools does not hit terminal limits.

#### Acceptance criteria
- [ ] Shift+Enter in the Claude Code prompt adds a new line, inside Zellij.
- [ ] Text copied in Zellij, sent through the terminal (OSC 52, without the `wl-copy`
  workaround), can be pasted in another Plasma app.
- [ ] If this passes, the `wl-copy` workaround is removed from the Zellij settings, so the copy
  goes through the terminal again (and also works in Zellij over SSH). If it does not pass, the
  workaround stays.
- [ ] Accepted by the operator: without the workaround, the Zellij copy no longer works in Konsole.
  Konsole is the fallback for when the new terminal does not start; there, the copy is a small
  loss.
- [ ] Output that redraws a lot (for example Claude Code while it works) shows no flicker or torn
  lines.
- [ ] A kitty-format image shows in the terminal, outside Zellij. Inside Zellij is not required
  (Zellij probably does not pass kitty images on).
- [ ] A link printed with OSC 8 opens in the browser on click.
- [ ] A true-colour test shows smooth colour gradients.

#### Behaviour
The operator opens the terminal; Zellij starts as now; the tools work without extra settings by hand.

#### Errors and edge cases
- A feature that works outside Zellij but not inside: noted in the comparison (Story 1); it does not
  block the change if Zellij is the cause.

### Story 3: It is at home in Plasma
**As the** operator, **I want** the chosen terminal on every Plasma host, looking like a normal
Plasma window, **so that** the daily desktop stays one calm, consistent desktop.

#### Acceptance criteria
- [ ] The terminal is installed on every host with Plasma as its graphical session, and can be
  started from the Plasma launcher.
- [ ] It starts and is not clearly slow on `truce`, the oldest host.
- [ ] The window has the normal Plasma title bar (window name, minimize, maximize, close), drawn by
  Plasma as on every other window. There are no extra buttons.
- [ ] There is no scroll bar, menu bar, toolbar or tab bar.
- [ ] It uses the same monospace font as the rest of the setup.
- [ ] It has a light and a dark theme and follows the light/dark mode that Plasma shows, also when
  that mode changes while the terminal is open.
- [ ] All of the above holds right after a rebuild, with no setting made by hand.
- [ ] Konsole stays installed and works as before.
- [ ] Plasma opens the new terminal by default: the keyboard shortcut for a terminal and "Open
  terminal" in the file manager start it, not Konsole.

#### Behaviour
The operator rebuilds a Plasma host and opens a terminal with the keyboard shortcut, the launcher or
the file manager. The new terminal opens with Zellij, in the right font and in Plasma's light or
dark mode, with only the Plasma title bar around it.

#### Errors and edge cases
- The terminal does not start (for example a graphics problem on `truce`): Konsole is still there,
  so the daily desktop keeps working.

### Story 4: Bonus – the same terminal in niri
**As the** operator, **I want** the chosen terminal to work in niri too, if it is easy, **so that**
I use one terminal in both graphical sessions.

#### Acceptance criteria
- [ ] If the chosen terminal works well in niri, it replaces Alacritty there, with the theme that
  niri uses.
- [ ] If it does not, Alacritty stays in niri and this story is dropped without blocking the change.

## Interface
- The chosen terminal in the Plasma launcher, next to Konsole.
- No new commands. The terminal settings are part of the repository and apply after a rebuild.
- The comparison table in this spec, updated with checked results and the choice.

## Consistency
- Konsole stays installed: the principle "do not remove a working experiment" and the "try
  something new" journey.
- The font and light/dark theme follow the setup that the rest of the repository uses.
- Zellij still starts in every new shell, as now.

## What changes for existing users
No breaking changes. A new terminal is added on every Plasma host; Konsole stays. In niri,
Alacritty may be replaced (Story 4).

## Warnings from architect and engineer
- **Old hardware.** Ghostty draws with the GPU (OpenGL). On `truce` (an old laptop) it may not
  start or may be slow. This is a pass/fail check in Story 3.
- **Zellij sits in the middle.** Each feature must pass through Zellij 0.45. Images and the
  keyboard protocol are the most likely to fail there. A failure must be traced to the terminal or to
  Zellij.
- **Konsole has OSC 52 (write only) since 2024**, according to its documentation, but the Zellij
  copy through the terminal fails in Konsole in practice. The trial must test the copy through the
  terminal (without the workaround), not only a direct OSC 52 sequence; both are separate checks.
- **The workaround hides the problem.** With `wl-copy`, the Zellij copy works in every terminal, so a
  trial with the normal Zellij settings proves nothing about OSC 52.
- **Settings by hand are not allowed.** Each extra that must be hidden (header bar, tab bar, scroll
  bar) is one more setting that the repository must manage, on every host. A terminal with fewer
  extras is leaner to maintain, too.
- **Theme in two places.** Plasma manages its own theme; the repository's light/dark setting is used
  outside Plasma. In Plasma, the terminal follows the mode that Plasma shows (decided 2026-10-11).
- **Development builds.** WezTerm in the stable channel is a development build, not a release. That
  can mean more change between updates.

## Not in scope
- Removing Konsole.
- Changes to Zellij other than removing the `wl-copy` workaround; the automatic start of Zellij.
- Settings inside Claude Code or pi agent, except what a check needs.
- Terminals other than Ghostty, unless Ghostty fails (then kitty, see Story 1).
- macOS.

## Open questions
- None. Decided 2026-10-11: the trial (Story 1) runs in Discover, before the spec is approved, so
  that Design knows the chosen terminal. It needs no change to the repository.

## Spec review
<Filled in by `/review spec` (a fresh agent). One row per user story. Design does not start
without this table. A "does not serve" row sends the spec back to Discover.>

| Story | What the user is doing here | Verdict | Note |
|---|---|---|---|
| 1. Choose with checked facts | Picking the terminal for daily LLM work on facts, not feature lists | serves – note | The deciding trial (images) ran outside Zellij, but the operator always works inside Zellij (Context). As far as known, Zellij does not pass kitty images on, so the one check that put WezTerm out may not matter in daily use, while Shift+Enter and the copy (the real pains from the idea) were not tried on Linux. The choice still stands on other grounds (same terminal as macOS) and Story 1 has a fallback to kitty. Checked: read the trial table; Zellij image support not checked. |
| 2. Modern features in my real setup | Typing multi-line prompts and copying from Zellij, locally and over SSH, without hitting terminal limits | serves – note | Shift+Enter and the copy are the operator's real pains and are tested inside Zellij: good. But removing the `wl-copy` workaround changes Zellij for every terminal, so the copy then breaks in Konsole, the fallback that Story 3 and core value 4 rely on. The spec should say this trade-off is accepted (or keep a local fallback). The image criterion allows "outside Zellij", which the operator never uses; name it as a nice-to-have rather than a feature that works. Checked: search `copy_command` in `modules/` (one shared setting in `modules/home/programs/zellij/default.nix`). |
| 3. At home in Plasma | Opening a terminal on any Plasma host after a rebuild and finding it fitting the daily desktop | serves – note | Fits core values 3 and 4 and the "no setting by hand" rule. Two points for Design to settle from the user's view: (a) "follows the light/dark theme that the host uses" – the repository's theme setting is used only outside Plasma, so the spec should say which one wins in Plasma (the warning names the conflict, the criterion does not decide it); (b) the default terminal is only "nice to have", yet the operator's quickest way to a terminal (shortcut, "Open terminal" in the file manager) would then still open Konsole, which lacks the features. Checked: search `settings.theme` in `modules/home/theme/default.nix` (gated on niri; comment "Plasma manages its own theme"). |
| 4. Bonus – same terminal in niri | Using one terminal in both graphical sessions | serves | Optional and never blocking, as the vision says for the playground. Checked: read vision principles. |

Reviewed 2026-10-11 by `/review spec` (fresh agent). No story conflicts with the vision. Side
note: most acceptance criteria in Stories 2 and 3 are hand checks on real hosts (including
`truce`); the `closure: checks` in `change.md` cannot see them – for Design to weigh.

Fixed in the spec on 2026-10-11, with the operator: Story 1 (note that the image test ran outside
Zellij and weighs less), Story 2 (image outside Zellij only; the loss of the Zellij copy in Konsole
is accepted), Story 3 (the terminal follows Plasma's light/dark mode; default terminal is now
required). The side note on hand checks goes to Design. No second round: the changes follow from
the review.
