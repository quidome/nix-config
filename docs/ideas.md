# Ideas

Raw ideas, one line each. No judgement yet. `/vision idea: …` picks them up.
Add the date. Remove a line when it becomes a change, or mark it `(rejected: reason)`.

- 2026-10-11 Research: should containers move from Docker to Podman (rootless, no daemon)? A switch needs a plan for existing images and volumes. See decision 0001.
- 2026-10-11 Root SSH login on installed hosts is used only for remote switch, boot and gc in the justfile; decide if it stays or moves to user + sudo.
- 2026-10-11 Back up the git-crypt key, and write down how to restore it (left out of the secret management change).
- 2026-10-11 Set the default terminal and its keyboard shortcut in Plasma from the repository, maybe as a system-wide default (`kdeglobals` in `/etc/xdg`) under the operator's own settings; now a hand step (terminal for Plasma change).
- 2026-10-11 Let Zellij and the other tools follow Plasma's light/dark mode, as Ghostty does, instead of the repository's fixed light/dark setting (found in the terminal for Plasma change).
