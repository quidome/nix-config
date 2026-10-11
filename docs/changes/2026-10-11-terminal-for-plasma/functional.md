# Functional spec: Terminal for Plasma

**Status**: draft
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

## User stories

### Story 1: Choose with checked facts
**As the** operator, **I want to** try each candidate against my needs before I choose, **so
that** the choice rests on how it works in my real setup, not on feature lists.

#### Acceptance criteria
- [ ] Each candidate (Ghostty, kitty, WezTerm, and Konsole on condition) is tried on a Plasma host,
  with Zellij and Claude Code, and the comparison table above is updated with the checked result
  for each cell ("checked: yes / no / with setting").
- [ ] For Konsole, the trial first checks Shift+Enter in Claude Code and the Zellij copy through
  the terminal (without the `wl-copy` workaround). If one of them cannot be made to work, Konsole
  leaves the comparison and stays only as the fallback.
- [ ] Each candidate is started on `truce`, the oldest host; one that does not start or is
  clearly slow there fails.
- [ ] The operator chooses one candidate; the choice and the reason are written in this spec.

#### Behaviour
The operator starts each candidate on a Plasma host without changing the configuration of the host,
runs the checks of Story 2, looks at the window (Story 3), and fills in the table. Then the
operator chooses.

#### Errors and edge cases
- No candidate passes every need: the operator chooses the best one and writes down which need is
  not met and why that is acceptable, or the change goes back to `/vision`.
- A feature fails only inside Zellij: the table says so; the cause (terminal or Zellij) is named,
  because a Zellij problem does not count against the terminal.

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
- [ ] Output that redraws a lot (for example Claude Code while it works) shows no flicker or torn
  lines.
- [ ] A kitty-format image shows in the terminal (outside Zellij is acceptable if Zellij does not
  pass images on; the spec then says so).
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
- [ ] The window has the normal Plasma title bar (window name, minimize, maximize, close), drawn by
  Plasma as on every other window. There are no extra buttons.
- [ ] There is no scroll bar, menu bar, toolbar or tab bar.
- [ ] It uses the same monospace font as the rest of the setup, and follows the light/dark theme
  that the host uses.
- [ ] All of the above holds right after a rebuild, with no setting made by hand.
- [ ] Konsole stays installed and works as before.
- [ ] Nice to have, not required: Plasma opens the new terminal by default (keyboard shortcut,
  "Open terminal" in the file manager).

#### Behaviour
The operator rebuilds a Plasma host and starts the terminal from the launcher. It opens with Zellij,
in the right font and theme, with only the Plasma title bar around it.

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
- **Old hardware.** Ghostty, kitty and WezTerm draw with the GPU (OpenGL). On `truce` (an old
  laptop) a candidate may not start or may be slow. This is a pass/fail check in Story 1.
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
  outside Plasma. The terminal must follow what the host really shows, and the two may disagree.
- **Development builds.** WezTerm in the stable channel is a development build, not a release. That
  can mean more change between updates.

## Not in scope
- Removing Konsole.
- Changes to Zellij other than removing the `wl-copy` workaround; the automatic start of Zellij.
- Settings inside Claude Code or pi agent, except what a check needs.
- Terminals other than the four candidates (Alacritty and foot are out because of images).
- macOS.

## Open questions
- None. Decided 2026-10-11: the trial (Story 1) runs in Discover, before the spec is approved, so
  that Design knows the chosen terminal. It needs no change to the repository.

## Spec review
<Filled in by `/review spec` (a fresh agent). One row per user story. Design does not start
without this table. A "does not serve" row sends the spec back to Discover.>

| Story | What the user is doing here | Verdict | Note |
|---|---|---|---|
