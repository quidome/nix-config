# GNOME follow-up plan

Scope: follow-up from the review of `f1a54a9a0230a3fe91aa7a32010ad70f6d5c085f^..HEAD`.

Implementation is handled one topic at a time. Close and commit each topic before moving to the next, keeping the worktree changes small and reviewable.

## Completed topics

### 1. Input-remapper security boundary

Resolved by restricting the system D-Bus policy for input-remapper 2.2.0, pinned through nixpkgs revision `062346a6d85bc4b49dfaa61c986e9c5be21217d1`:

- only `root` may own `inputremapper.Control`;
- only the single non-root Home Manager desktop user may send requests to it;
- configurations with more than one non-root Home Manager user fail closed at evaluation time; and
- session autoload now runs `stop-all && autoload`, so cleanup failure is visible and prevents new mappings from loading.

A disposable NixOS VM using dbus-broker reproduced the original issue: an unrelated user could invoke `hello`, `stop-all`, and `quit`, including stopping the root daemon. The restricted policy allowed the configured desktop user to call `hello` while an unrelated user was denied all three calls and the daemon remained active. The policy covers injection methods because it denies all messages to the daemon destination, not only the tested commands.

## 1. Resolve the input-remapper security boundary first

- Reproduce the reported behavior from a non-root account in a disposable/test environment.
- Inspect the exact nixpkgs input-remapper D-Bus policy and daemon methods used by the current lockfile.
- Determine the supported safe design:
  - restrict D-Bus ownership and method calls to the intended user/session, or
  - avoid the root daemon and use a per-user mechanism, or
  - disable input-remapper by default until a safe design is available.
- Do not rely on `stop-all || true`; cleanup failures must not silently leave mappings active across sessions.
- Add focused documentation/configuration comments if the service remains enabled.
- Acceptance: an unprivileged unrelated local user cannot control another user’s mappings, inject global input through the root daemon, or stop the service; session cleanup failure is observable and fail-closed.

## 2. Decide and document default input-remapper policy

- Decide whether GNOME hosts should enable input-remapper automatically.
- If optional, change the system setting to a host-overridable default (`mkDefault`) and document the opt-in path.
- If mandatory, document why and provide the required authorization boundary.
- Remove the unreachable `niri` branch from `modules/home/desktop/input-remapper.nix` unless Niri support is intentionally restored.

## 3. Repair GNOME extension package/activation consistency

Compare:

- `modules/system/desktop/gnome.nix`
- `modules/home/desktop/gnome.nix`
- `modules/home/settings.nix`

Then choose one consistent policy for each extension:

- AppIndicator: install and enable it, or remove its default enablement.
- Caffeine: enable it if installed, or stop installing it by default.
- Tailscale status: conditionally enable it whenever its package is installed and the relevant service is enabled.
- Recheck whether the previous Bea/Nimbus-specific AppIndicator behavior should be restored.

Acceptance: every enabled extension has a corresponding package, and every installed optional extension is either deliberately available-only or explicitly enabled.

## 4. Make input-remapper lifecycle behavior reliable

- Test login, delayed device availability, hotplug, suspend/resume, logout/login, and multi-user transitions.
- Enable and validate udev rules only if the security review approves the resulting policy.
- Replace the one-shot login-only behavior if a supported event-driven mechanism exists.
- Decide how declarative `/nix/store` config should interact with GUI edits and future config-schema migrations; prefer a writable state/config path where upstream requires writes.

Acceptance: configured devices load after login and after hotplug/resume, missing devices do not produce a false-success state, and mappings cannot persist across users or sessions.

## 5. Handle desktop-manager transitions explicitly

- Keep GDM/GNOME evaluation checks for `bea` and `nimbus`.
- For a host currently running SDDM/Plasma, use a planned reboot or approved display-manager restart; do not assume `switch` changes the active display manager immediately.
- Do not run `just switch`, `just boot`, or rollback without explicit approval.

## 6. Treat the Pi npm risk as a separate task

The `965626e` runtime npm installation is unrelated to GNOME. Track it separately:

- evaluate whether `pi-subagents` can be packaged/pinned declaratively;
- use an integrity-locked dependency tree and avoid unneeded lifecycle scripts;
- decide whether sandboxing should be enabled by default;
- document the credential/network boundary if runtime installation remains.

## Validation checklist

Run after each focused change, without activating a host:

```sh
just check
just lint
nix build --dry-run .#nixosConfigurations.bea.config.system.build.toplevel
nix build --dry-run .#nixosConfigurations.nimbus.config.system.build.toplevel
```

Also run `alejandra --check .`, `statix check .`, `deadnix .`, and `git diff --check` when applicable. For runtime behavior, use a disposable/test host or VM and record the exact nixpkgs/input-remapper version and D-Bus policy tested.

Before any commit, inspect changed files, confirm no protected files were touched, run `git-crypt status`, and keep security remediation separate from cosmetic GNOME cleanup where practical.
