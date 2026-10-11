---
title: Containers standard on every host
type: technical
stage: done
closure: checks
created: 2026-10-11
---

# Containers standard on every host

Container support is now set up per host (`nimbus`, `bea`). Make it part of the shared base, so
every host has it, and remove the copies from the host files.

## Log
| Date | Stage | Note |
|------|-------|------|
| 2026-10-11 | design | created from backlog item (technical debt in architecture.md) |
| 2026-10-11 | implement | technical spec approved; closure: checks (settings move only; evals and nimbus closure diff prove it) |
| 2026-10-11 | close | steps 1-2 done; just verify passes; nimbus closure unchanged, bea and truce only additions; closure checks: no review needed |
| 2026-10-11 | done | living docs updated, decision 0001 written; ready to deploy, real-host test on truce not done yet |
