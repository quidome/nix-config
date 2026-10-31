# Ideas

Raw ideas, one line each. No judgement yet.
Add the date. Remove a line when it moves to the backlog, or mark it `(rejected: reason)`.

- 2026-10-11 Research: should containers move from Docker to Podman (rootless, no daemon)? A switch needs a plan for existing images and volumes. See decision 0001.
- 2026-10-11 Root SSH login on installed hosts is used only for remote switch, boot and gc in the justfile; decide if it stays or moves to user + sudo.
- 2026-10-11 Back up the git-crypt key, and write down how to restore it (left out of the secret management change).
- 2026-10-11 Set the default terminal and its keyboard shortcut in Plasma from the repository, maybe as a system-wide default (`kdeglobals` in `/etc/xdg`) under the operator's own settings; now a hand step (terminal for Plasma change).
- 2026-10-11 Let Zellij and the other tools follow Plasma's light/dark mode, as Ghostty does, instead of the repository's fixed light/dark setting (found in the terminal for Plasma change).
- 2026-10-25 Fingerprint on nimbus (Goodix `27c6:533c`) is unreliable: the closed Goodix TOD driver 0.0.6 (last release 2020, newest in nixpkgs, unstable and upstream; open `libfprint` lists this sensor as unsupported) crashes `fprintd` with a double free when it releases the reader after a check. Journal 19 Jul–25 Oct: crashes in about 1 of 7 checks under GNOME, 1 of 4 under Plasma, 1 of 3 under niri; same order with fixed `fprintd`/PAM versions, so the desktop changes only how often the bug triggers. `fprintd` is D-Bus activated, so a crash mostly goes unnoticed; the visible failure is `libgxfp_start_session failed` (reader never starts a scan, no hint on the Plasma lock screen; seen 3 times on 2026-10-25 after resume). Options: live with it, password-only lock screen, or an external reader that open `libfprint` supports.
- 2026-10-31 Troubleshoot the old disks that lie around. Some may hold ZFS: `bea` had ZFS support for this, now commented out in `hosts/bea/system.nix`; turn it on again for that project. The base install image can also read ZFS.
