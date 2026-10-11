---
title: Secret management
type: feature
stage: implement
closure: review build + accept
created: 2026-10-11
---

# Secret management

Decide which values in this repository are secrets, where they are stored, and which tool
manages them (git-crypt now; sops-nix, agenix or another tool are options). Includes the
WireGuard key on `nimbus` and the question if the user account must stay hidden.

## Log
| Date | Stage | Note |
|------|-------|------|
| 2026-10-11 | discover | created from `ideas.md`; absorbs backlog items "user account plain or hidden" and (as test case) "WireGuard key" |
| 2026-10-11 | discover | scope decided: option A – write the secret rule, remove the double password hash, add a leak guard, keep git-crypt; tool choice moves to the WireGuard change. Hardware configuration made plain text as a separate small fix. |
| 2026-10-11 | discover | /vision: password hash exception and value classes added to vision.md; five words added to language.md |
| 2026-10-11 | discover | spec review round 1: all serve with notes; N1-N6 fixed in the spec with the operator |
| 2026-10-11 | discover | spec review round 2: all serve, notes N7-N10 fixed; /vision aligned language.md and vision.md |
| 2026-10-11 | design | functional spec approved by the operator |
| 2026-10-11 | implement | technical spec approved; closure: review build + accept (the leak guard is a safety net that fails silently if it has a hole; the rule document is the main protection) |
