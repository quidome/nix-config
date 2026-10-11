# Backlog

Open work, most important first. Changes link to their folder; small fixes are one line.
Background for each item: "Known technical debt" in `architecture.md`.

1. [Terminal for Plasma](changes/2026-10-11-terminal-for-plasma/) – implement
2. technical: remove the `server` form factor – `/vision` first (word list), then `/design`
3. check: does an encrypted file use `/persist`? Operator runs `grep -l persist` on the encrypted files; then remove it or give it a purpose
4. product doc: write down how the WireGuard key on `nimbus` is set up, in the workstations document in `docs/product/` (or let the configuration provide it) – parked: becomes the host secret change (tool choice: git-crypt, sops-nix, agenix), after [Secret management](changes/done/2026-10-11-secret-management/)
