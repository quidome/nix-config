---
title: Terminal for Plasma
type: feature
stage: implement
closure: review accept
created: 2026-10-11
---

# Terminal for Plasma

Find and set up a lean terminal emulator with the modern terminal features that the operator's
daily tools need, and that works well in Plasma. Konsole stays as a fallback.

## Log
| Date | Stage | Note |
|------|-------|------|
| 2026-10-11 | idea | created from `ideas.md` |
| 2026-10-11 | discover | /vision: fits the vision (tool for the main daily work, "try something new" journey); options to be explored, no preferred candidate |
| 2026-10-11 | discover | trial: Konsole out (Shift+Enter), WezTerm out (images); operator chose Ghostty, kitty as next candidate; `wl-copy` workaround goes if OSC 52 passes |
| 2026-10-11 | design | spec review: all serve, notes fixed with the operator (Konsole copy loss accepted, follow Plasma light/dark, default terminal required); functional spec approved by the operator |
| 2026-10-11 | design | functional spec changed with the operator: the default terminal and its shortcut are a written hand step (Plasma writes these settings itself) |
| 2026-10-11 | implement | technical spec approved (6 steps: truce first, Plasma, Zellij copy, niri with check on truce, product doc, truce); spec review of deviations: notes fixed with the operator; Mod+Enter / Meta+Enter as terminal key; closure: review accept (most criteria are hand checks on real hosts that the checks cannot see) |
