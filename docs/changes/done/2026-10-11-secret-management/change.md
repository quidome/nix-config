---
title: Secret management
type: feature
stage: done
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
| 2026-10-11 | implement | steps 1-3 done; build review: R1-R5, accept review: accepted with notes A1-A9; R1, R2 (guard stops on unsupported `.gitattributes` rules; apr1 and argon2 hashes) fixed as an agreed deviation, so the build review runs again on the new guard |
| 2026-10-11 | close | build review round 2: R6-R8 fixed (guard stops on other filters, macros, read errors); no third round, agreed with the operator; spec done |
| 2026-10-11 | done | closed: architecture.md (secret rows, scripts, debt), vision.md (where we are), decision 0002; folder moved to changes/done/ |
