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

### 2. Default input-remapper policy

Resolved as opt-in. `settings.inputRemapper.enable` defaults to `false`, and the Home Manager configuration is gated by the same setting so a disabled system daemon does not leave a failing autoload unit behind. Bea and Nimbus explicitly opt in to preserve their existing mouse mappings. The stale Niri branch was removed because Niri is not a supported GUI value in this repository.

### 3. GNOME extension package/activation consistency

Resolved by keeping the GNOME extension set declarative and deriving activation from package availability:

- AppIndicator, Caffeine, and Display Configuration Switcher are installed and enabled when available.
- Tailscale Status is installed and enabled only when `services.tailscale.enable` is true and the extension is available.
- AppIndicator remains enabled by the existing GNOME setting; no separate Bea/Nimbus-specific override was present to restore.

The evaluated Bea configuration contains matching packages and enabled-extension UUIDs for AppIndicator, Caffeine, and Display Configuration Switcher. `just check`, `just lint`, `alejandra --check .`, both host dry-runs, and `git diff --check` passed.

### 4. Input-remapper lifecycle behavior

Resolved without enabling the pinned package's root udev rule, which NixOS leaves disabled because of upstream issue #140. The user session now:

- performs `stop-all && autoload` once after `graphical-session.target`, and refuses to autoload if cleanup fails;
- remains bound to `graphical-session.target` and runs `stop-all` when the session ends; and
- retries `autoload` every 10 seconds from a user systemd timer, covering delayed device availability and hotplug/resume without invoking a root udev command.

The timer requires successful session initialization, uses one-second timer accuracy, and is stopped with the graphical session. This preserves the single-user D-Bus boundary established in topic 1. Evaluation confirmed the generated user service/timer relationships; `just check`, `just lint`, `alejandra --check .`, both host dry-runs, and `git diff --check` passed.

### 5. Desktop-manager transitions

No configuration change was needed. Evaluation confirms that both `bea` and `nimbus` select `settings.gui = "gnome"`, enable GDM, and disable SDDM. The live transition remains intentionally operational: a host currently running SDDM/Plasma needs a planned reboot or an explicitly approved display-manager restart; `switch` alone is not assumed to change the active session.

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

Resolved separately from GNOME. Pi now loads `pi-subagents` from its Git repository at
commit `83be9c3de2cde1553c0269f383efc1eb1194dc8b` (the `v0.65.1` tag target),
rather than resolving a mutable npm range. The pinned repository includes a
versioned npm lockfile with integrity metadata for the dependency tree.

Pi-managed npm commands are configured with `--ignore-scripts`, `--no-audit`,
`--no-fund`, and `--omit=dev`. This prevents dependency lifecycle scripts,
dev-only dependencies, and unnecessary registry audit/funding requests during
installation; it does not make the extension trusted code.

The Pi jail remains opt-in. It would not isolate an extension from Pi's agent
configuration directory, which must remain writable for settings, package state,
and credentials, and it can interfere with the configured external-tool/SSH
workflow. The remaining boundary is documented: initial package/dependency
installation requires network access, and the extension runs as the same user
as Pi with access to the agent directory, current working directory, configured
external tools, and Pi's model/network credentials. Do not install or run an
unreviewed Pi package in this profile.

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
