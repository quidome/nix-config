# Terminal

What it does **now**, for the operator. Update it when a change affects it.

## Purpose
Most daily work happens in a terminal, with LLM tools such as Claude Code and pi agent inside
Zellij. The terminal must give the modern features that these tools use, stay out of the way, and
look like a normal window of the graphical session.

## Behaviour
- **Ghostty** is the terminal on every host with a graphical session: Plasma and niri. Every new
  shell starts Zellij, as before.
- **Modern features** (checked on `nimbus` in Plasma): Shift+Enter adds a new line in Claude Code,
  inside Zellij; Zellij copies through the terminal (OSC 52) to the clipboard of the session; kitty
  images show, also inside Zellij; links (OSC 8) open on click; true colour; no flicker while a
  program redraws a lot.
- **Window**: only the title bar that the graphical session draws (in Plasma the normal Plasma title
  bar; in niri none). No scroll bar; no tab bar with one tab; no menu or extra buttons.
- **Look**: font `JetBrainsMono Nerd Font`, size 12. Catppuccin Latte in light mode and Catppuccin
  Mocha in dark mode (the same flavours as Zellij); Ghostty follows the light/dark mode of the
  desktop, also while it is open.
- **SSH**: inside Zellij the terminal type is `xterm-256color`, which every host knows. Outside
  Zellij it is `xterm-ghostty`; over SSH, Ghostty then sends a known type or installs its own
  description on the other host.
- **Keys**: Mod+Enter opens a terminal – in niri from the repository; in Plasma (Meta+Enter) after
  the hand step below. In niri, the network item in the status bar opens `nmtui` in Ghostty.
- **Konsole** stays installed in Plasma as the fallback, with its own settings.

## Errors and limits
- **Konsole and the Zellij copy**: Zellij copies through the terminal, and that does not reach the
  clipboard from Konsole. In Konsole, the Zellij copy does not work (accepted: Konsole is only the
  fallback).
- **One process for all windows**: Ghostty runs as one user service. If it stops with an error, all
  its windows close. After a rebuild, open windows keep the old settings until the service
  restarts. A window gets its environment from the service, not from the shell that starts it; for
  a separate process use `ghostty --gtk-single-instance=false`.
- **Light/dark in two places**: Ghostty follows Plasma's light/dark mode, but Zellij and the other
  tools (helix, git, the prompt) follow the repository's light/dark setting. When the two differ,
  the tools show the other mode's colours inside Ghostty. Keep Plasma's mode and the repository
  setting the same.
- **Not yet checked**: Ghostty on `truce` (the oldest host, with an old GPU), and Ghostty in a real
  niri session. Until the niri check passes, the Alacritty colours stay in the theme module.

## Interface
- Settings: `modules/home/programs/ghostty.nix` (only values that differ from Ghostty's defaults).
  Enabled in `modules/home/desktop/plasma.nix` and `modules/home/desktop/niri/default.nix`.
- Zellij settings: `modules/home/programs/zellij/`.
- **Hand step after a rebuild (Plasma)** – Plasma writes these settings itself, so the repository
  does not manage them:
  1. System Settings → Default Applications → Terminal emulator: **Ghostty**. "Open terminal" in the
     file manager then starts Ghostty.
  2. System Settings → Keyboard → Shortcuts: add Ghostty and give it **Meta+Enter**. This is the only
     terminal shortcut; Ctrl+Alt+T stays as Plasma sets it.

  Do these steps again after `desktop-reset kde`: it moves the Plasma settings files aside, and
  these settings with them.
