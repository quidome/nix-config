# Backlog

Open work, most important first. Changes link to their folder; small fixes are one line.
Background for each item: "Known technical debt" in `architecture.md`.

1. small: remove the dead `gnome` value from `modules/system/desktop/electron-desktop.nix`
2. small: let `live-image/base.nix` import `modules/shared/settings.nix`, so there is one `authorizedKeys` option
3. technical: make containers standard on every host (Docker or Podman to decide) and move the JetBrains IDE to the `dev` role – start with `/design`
4. product doc: write down how the WireGuard key on `nimbus` is set up, in the workstations document in `docs/product/` (or let the configuration provide it)
5. technical: user account plain or hidden everywhere – decide in `/design`
6. technical: remove the `server` form factor – `/vision` first (word list), then `/design`
7. check: does an encrypted file use `/persist`? Operator runs `grep -l persist` on the encrypted files; then remove it or give it a purpose
