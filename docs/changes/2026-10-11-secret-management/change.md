---
title: Secret management
type: feature
stage: discover
closure: checks
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
