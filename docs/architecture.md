# Architecture: nix-config

How the repository is built **now**. Update it when a change affects it. The reasons for choices are in
`docs/decisions/`.

## Overview
One flake (`flake.nix`) builds a NixOS configuration for each host, with home-manager running
as a NixOS module, so one rebuild applies both system and user configuration. The flake also
builds two live install images.

```
flake.nix ── mkHost user host
               ├─ disko module                      disk layout
               ├─ modules/shared                    options (settings.*) + secret wiring
               ├─ modules/system                    NixOS: profiles, roles, desktop, services
               ├─ hosts/<host>/shared.nix           the host's choices (settings.*)
               ├─ hosts/<host>/system.nix           host-only system config + hardware
               └─ home-manager, one user
                    ├─ modules/shared               same options, same secret wiring
                    ├─ modules/home                 profiles, roles, desktop, programs, theme
                    ├─ hosts/<host>/shared.nix      the same choices again
                    └─ hosts/<host>/home.nix        host-only user config
```

The host's choices are read twice, once by the system and once by home-manager, so both sides
see the same `settings.*` values.

Inputs: `nixpkgs` (stable release), `unstable` (for single packages, passed as `pkgsUnstable`),
`home-manager` (matching release), `disko`, `claude-code`. One `pkgs` set for `x86_64-linux`,
with unfree packages allowed. All hosts use the same user, passed to modules as `desktopUser`.

## Layers and modules
| Part | Responsibility | Depends on |
|------|----------------|------------|
| `modules/shared/settings.nix` | The host choices as options: `gui`, `formFactor`, `roles.*`, `authorizedKeys` | – |
| `modules/shared/secrets.nix` | Private values: the authorized SSH public keys (encrypted with git-crypt) | – |
| `modules/system/secrets.nix` | The temporary initial password hash for the operator and `root`, the one secret exception (encrypted with git-crypt) | – |
| `modules/system/profiles/` | Always-on system base, including containers (Docker, shared container configuration); form-factor services (network, bluetooth, laptop power); graphical base (fonts, PipeWire, Flatpak) | `settings.formFactor`, `settings.gui` |
| `modules/system/roles/` | Optional software groups on the system side: `dev`, `personal`, `media`, `gaming` | `settings.roles`, `settings.gui` |
| `modules/system/desktop/` | Plasma (SDDM), niri (greetd), and a fix for Electron apps outside Plasma | `settings.gui`, `settings.roles.personal` |
| `modules/system/services/` | Service settings that turn on when the service is on (Flatpak repo, PipeWire, usbmuxd) | the service's own `enable` |
| `modules/system/disk-config.nix` | One shared disk layout (EFI + LUKS + btrfs subvolumes, swap file); a function of the disk device. The Docker storage driver in the base (btrfs) depends on it | disko |
| `modules/home/profiles/` | Always-on user base (shell, editors, git, ssh client); graphical base | `settings.gui` |
| `modules/home/roles/` | Optional groups on the user side: `dev`, `personal` | `settings.roles`, `settings.gui` |
| `modules/home/desktop/` | Plasma and niri user config, which turns on the terminal (Ghostty); `desktop-reset` tool | `settings.gui` |
| `modules/home/programs/` | Settings per program; active when the program is enabled elsewhere | the program's own `enable` |
| `modules/home/theme/` | Light/dark theme (`settings.theme`, home only); colors and fonts for sessions without their own theme (niri) | `settings.theme`, `settings.gui` |
| `hosts/<host>/` | `shared.nix` (choices), `system.nix`, `home.nix`, `disk-config.nix` (disk device), `hardware-configuration.nix` (generated, plain text), and encrypted `vars.nix`, `home-vars.nix` | modules |
| `scripts/` | The leak guard and its tests, run as flake checks (`leak-guard`, `leak-guard-test`) | `.gitattributes` |
| `live-image/` | Install images: base (ssh keys, sshd, nmtui) and a bcachefs variant | `modules/shared/settings.nix`, `modules/shared/secrets.nix` |

Hosts now: `nimbus` (laptop), `bea` (desktop), `truce` (laptop). None sets `gui`, so all three
use the default, plasma.

## Patterns to follow
- **A host chooses, modules implement.** `hosts/<host>/shared.nix` sets only `settings.*`. A host
  file adds only what is unique to that host: hardware, disk device, and software that only that
  host uses.
- **Defaults in modules use `lib.mkDefault`.** A module that needs something else turns it off
  with a plain assignment, not with `lib.mkDefault false`.
- **Conditional config with `lib.mkIf`** on `settings.*`; combine with `lib.mkMerge`.
- **Program modules configure, they do not enable.** `modules/home/programs/*` act under
  `lib.mkIf cfg.enable`; profiles and roles decide what is enabled.
- **GUI-only packages** in a role go behind `settings.gui != "none"`.
- **Host desktop overrides** in `home.nix` are gated with `lib.mkIf` on `settings.gui`, unless
  they work on every desktop.
- **niri config is a plain KDL file** (`config.kdl`); generated parts go into a separate included
  file and the whole is checked with `niri validate` at build time.
- **Every value has a class** (secret, private, public, identity) that decides where it lives:
  `docs/product/secrets.md`. Private values in git-crypt files (`.gitattributes`: `secrets.nix`,
  `vars.nix`, `home-vars.nix`, `system-vars.nix`). Never read or show them.
- **Code style:** `lib.` prefix, no `with lib;`; options → config; format with alejandra.
- **Checks:** `nix flake check` runs alejandra, statix and deadnix (`lint`), and the `leak-guard`
  check (with its tests, `leak-guard-test`); each host must build.

## Known technical debt
- **Alacritty colours not used.** `modules/home/theme/default.nix` still sets Alacritty colours, and
  `modules/home/theme/palette.nix` has four entries only for them (`black`, `brightBlack`, `white`,
  `brightWhite`). Nothing uses them since Ghostty replaced Alacritty in niri. Remove them after
  Ghostty is checked in a real niri session.
- **`/persist` has no known use.** `modules/system/disk-config.nix` makes a `/persist` subvolume,
  needed at boot, but no unencrypted file uses it. Root is not wiped at boot, so everything
  already survives a reboot. Find out if an encrypted file uses it; if not, remove it or give it
  a purpose (for example host keys, if root is ever wiped at boot).
- **WireGuard key is a manual, unwritten step.** `nimbus` reads `/etc/secrets/wg0-private`, a
  file made by hand. Either the configuration provides it, or the manual step is written down.
  The host secret change closes this (see `docs/product/secrets.md`).
