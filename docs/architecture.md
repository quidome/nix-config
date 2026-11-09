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
`home-manager` (matching release), `disko`, `claude-code`, `nix-index-database`, `zen-browser`. One `pkgs` set for
`x86_64-linux`, with unfree packages allowed. All hosts use the same user, passed to modules as `desktopUser`.

## Layers and modules
| Part | Responsibility | Depends on |
|------|----------------|------------|
| `modules/shared/settings.nix` | The host choices as options: `gui`, `formFactor`, `roles.*`, `authorizedKeys` | – |
| `modules/shared/secrets.nix` | Private values: the authorized SSH public keys (encrypted with git-crypt) | – |
| `modules/system/secrets.nix` | The temporary initial password hash for the operator and `root`, the one secret exception (encrypted with git-crypt) | – |
| `modules/system/profiles/` | Always-on system base, including containers (Docker, shared container configuration) a monthly btrfs scrub, and zswap in front of the swap file; form-factor services (network, bluetooth, laptop power); graphical base (fonts, PipeWire, Flatpak, `systemd-oomd` on user sessions) | `settings.formFactor`, `settings.gui` |
| `modules/system/roles/` | Optional software groups on the system side: `dev`, `personal`, `media`, `gaming` | `settings.roles`, `settings.gui` |
| `modules/system/desktop/` | Plasma (SDDM), GNOME (GDM), niri (greetd), a fix for Electron apps on niri, and the `desktop-reset` tool | `settings.gui`, `settings.roles.personal` |
| `modules/system/services/` | Service settings that turn on when the service is on (Flatpak repo, PipeWire, usbmuxd) | the service's own `enable` |
| `modules/system/disk-config.nix` | One shared disk layout (EFI + LUKS + btrfs subvolumes, swap file); a function of the disk device. The Docker storage driver (btrfs) and the scrub in the base depend on it | disko |
| `modules/home/profiles/` | Always-on user base (shell, editors, git, ssh client); graphical base (fonts, Wayland for Electron apps, the terminal Ghostty) | `settings.gui` |
| `modules/home/roles/` | Optional groups on the user side: `dev`, `personal` | `settings.roles`, `settings.gui` |
| `modules/home/desktop/` | GNOME and niri user config | `settings.gui` |
| `modules/home/programs/` | Settings per program; active when the program is enabled elsewhere | the program's own `enable` |
| `modules/home/theme/` | Light/dark theme (`settings.theme`, home only); colors and fonts for sessions without their own theme (niri) | `settings.theme`, `settings.gui` |
| `hosts/<host>/` | `shared.nix` (choices), `system.nix`, `home.nix`, `hardware-configuration.nix` (generated, plain text), and encrypted `disk-config.nix` (disk device), `vars.nix`, `home-vars.nix`; on `nimbus` also encrypted `system-vars.nix` (WireGuard) and `kanshi.nix` | modules |
| `scripts/` | The leak guard and its tests, run as flake checks (`leak-guard`, `leak-guard-test`) | `.gitattributes` |
| `live-image/` | Install images: base (ssh keys, sshd, nmtui) and a bcachefs variant | `modules/shared` |

Hosts now: `nimbus` (laptop, niri), `bea` (desktop, GNOME), `truce` (laptop, Plasma, the default:
it does not set `gui`).

## Patterns to follow
- **A host chooses, modules implement.** `hosts/<host>/shared.nix` sets only `settings.*`. A host
  file adds only what is unique to that host: hardware, disk device, and software that only that
  host uses.
- **Defaults in modules use `lib.mkDefault`.** A module that needs something else turns it off
  with a plain assignment, not with `lib.mkDefault false`.
- **Conditional config with `lib.mkIf`** on `settings.*`; combine with `lib.mkMerge`.
- **Program modules configure, they do not enable.** `modules/home/programs/*` act under
  `lib.mkIf cfg.enable`; profiles and roles decide what is enabled.
- **User configuration goes in home, a plain install on the system.** A program that is configured
  for the user with home-manager is in `modules/home/`. A package that only needs to be installed
  is in `environment.systemPackages`, not in `home.packages`.
- **GUI-only packages** in a role go behind `settings.gui != "none"`.
- **Host desktop overrides** in `home.nix` are gated with `lib.mkIf` on `settings.gui`, unless
  they work on every desktop.
- **niri config is a plain KDL file** (`config.kdl`); generated parts go into a separate included
  file and the whole is checked with `niri validate` at build time.
- **Every value has a class** (secret, private, public, identity) that decides where it lives:
  `docs/product/secrets.md`. Private values in git-crypt files (`.gitattributes`: `secrets.nix`,
  `vars.nix`, `home-vars.nix`, `system-vars.nix`, and some host files by exact path). Never read or show them.
- **Code style:** `lib.` prefix, no `with lib;`; options → config; format with alejandra.
- **Checks:** `nix flake check` runs alejandra, statix and deadnix (`lint`), and the `leak-guard`
  check (with its tests, `leak-guard-test`). It only evaluates the hosts; `just build HOST` builds
  one.

## Known technical debt
- **Alacritty colours not used.** `modules/home/theme/default.nix` still sets Alacritty colours, and
  `modules/home/theme/palette.nix` has four entries only for them (`black`, `brightBlack`, `white`,
  `brightWhite`). Nothing uses them since Ghostty replaced Alacritty in niri. Remove them after
  Ghostty is checked in a real niri session.
- **WireGuard key is a manual, unwritten step.** `nimbus` reads `/etc/secrets/wg0-private`, a
  file made by hand. Either the configuration provides it, or the manual step is written down.
  The host secret change closes this (see `docs/product/secrets.md`).
