# Idea: Terminal for Plasma

**Status**: ready for discovery
**Vision fit**: serves core value 4 and priority 4 (the daily desktop always works) for the
operator's main daily work, and follows "add new tools when they are needed" and the "try
something new" journey (Konsole stays as a fallback).
**Date**: 2026-10-11

## The problem
Most daily work, including work with LLM tools such as Claude Code and pi agent, happens in a
terminal. Konsole, the terminal that comes with Plasma, does not support the modern terminal
features that these tools and Zellij (a terminal multiplexer) expect. Example: the Zellij command
that copies to the clipboard does not work in Konsole.

## The idea
A lean terminal that works well in Plasma and has all modern terminal features:
- copy to the clipboard through the terminal (OSC 52), as Zellij uses it;
- the extended keyboard protocol, so key combinations such as Shift+Enter reach the program;
- synchronized output (screen updates without flicker);
- images in the terminal;
- clickable links;
- true colour.

Lean: no tabs and no multiplexer of its own are needed; Zellij does that work.

The work is to explore the options (for example Ghostty, WezTerm, kitty, Alacritty, foot) and
choose one with the operator. There is no preferred candidate.

## Why now
The operator uses LLM tools every day, and the missing features get in the way now.

## How it fits
- Core value 4: Plasma is the daily desktop and must always work; the new terminal must not
  break it, and Konsole stays installed as a fallback.
- Principle: do not remove a working experiment; Konsole is kept.
- No effect on secrets, data on disk or rebuild speed.

## User view
- For the operator, on every host with Plasma as its graphical session.
- It is a bonus if the terminal also works in niri (the playground); on niri the operator
  probably uses Alacritty now.
- The operator also uses Ghostty on macOS; the same terminal everywhere would be a gain, not a
  requirement.

## Open questions
- Which candidates have all the modern features, and how lean is each one?
- What does "works well in Plasma" mean, and how is it checked (theme light/dark, fonts, window
  decoration, launcher, default terminal)?
- Does it follow the existing theme setting of the repository?
- Is it the default terminal in Plasma, or only installed next to Konsole?
- Does the choice also work in niri, and does it replace Alacritty there (bonus only)?
