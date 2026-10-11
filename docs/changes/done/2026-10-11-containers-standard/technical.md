# Technical spec: Containers standard on every host

**Status**: done
**Size**: story
**Change**: docs/changes/2026-10-11-containers-standard/
**Date**: 2026-10-11

## Objective
Move the container setup (Docker engine and shared container configuration) from the host files
into the always-on system base, and the container tools into the `dev` role, so every host has
the same setup.

## Requirements summary
Technical change, no functional spec.

- **Reason:** the container setup is copied into `hosts/nimbus/system.nix` and
  `hosts/bea/system.nix`; `truce` has none. The principle "a host chooses, modules implement"
  (`docs/architecture.md`) says shared setup lives in modules.
- **Expected result:**
  - Every host has Docker with the btrfs storage driver and the shared container configuration
    (`/etc/containers`), from `modules/system/profiles/base.nix`, as `lib.mkDefault` values.
  - Every host with the `dev` role has `docker-compose` and `lazydocker`.
  - No host file contains container settings or container tools.
- **Confirmed with the operator (2026-10-11):** Docker now, not Podman; tools in the `dev` role,
  not the base; `virtualisation.containers.enable` in the base too; JetBrains IDE is a separate
  backlog item.

## Current state
- `hosts/nimbus/system.nix`:
  - `virtualisation = { containers.enable = true; docker.enable = true; docker.storageDriver = "btrfs"; };`
  - `docker-compose` and `lazydocker` in `environment.systemPackages`.
- `hosts/bea/system.nix`: `virtualisation.docker.enable = true;` and
  `virtualisation.docker.storageDriver = "btrfs";`
- `hosts/truce/system.nix`: no container settings.
- `modules/system/profiles/base.nix`: top-level attributes (no `config =` wrapper), all
  defaults with `lib.mkDefault`.
- `modules/system/roles/dev.nix`: package list under `lib.mkIf cfg.roles.dev.enable`, grouped by
  comments (`# git`, `# devops tooling`, `# languages and linters`, `# coding agents`), with a
  `lib.optionals (cfg.gui != "none")` tail for GUI tools.
- All hosts use the shared btrfs disk layout (`modules/system/disk-config.nix`).
- The user's `docker` group membership is in the encrypted user definition; it does not change.

## Steps

### Step 1: Container engine in the base
- **Goal**: every host gets Docker and the shared container configuration from the base; the
  host files no longer set them.
- **Changes**:
  - `modules/system/profiles/base.nix`, top level, next to `services.openssh`:
    ```nix
    virtualisation = {
      containers.enable = lib.mkDefault true;
      docker = {
        enable = lib.mkDefault true;
        # All hosts use the shared btrfs disk layout (modules/system/disk-config.nix).
        storageDriver = lib.mkDefault "btrfs";
      };
    };
    ```
  - `hosts/nimbus/system.nix`: remove the whole `virtualisation` block.
  - `hosts/bea/system.nix`: remove both `virtualisation.docker.*` lines.
- **Tests**: for each of `nimbus`, `bea`, `truce`, `nix eval` gives:
  - `.config.virtualisation.docker.enable` → `true`
  - `.config.virtualisation.docker.storageDriver` → `"btrfs"`
  - `.config.virtualisation.containers.enable` → `true`

### Step 2: Container tools in the `dev` role
- **Goal**: `docker-compose` and `lazydocker` come from the `dev` role, not from a host.
- **Changes**:
  - `modules/system/roles/dev.nix`: new group after `# devops tooling`:
    ```nix
    # containers
    docker-compose
    lazydocker
    ```
    Not behind the GUI condition: both are terminal tools.
  - `hosts/nimbus/system.nix`: remove `docker-compose` and `lazydocker` from
    `environment.systemPackages`.
- **Tests**:
  - For each host, the names in `.config.environment.systemPackages` include `docker-compose`
    and `lazydocker` (all three hosts have `dev` on).
  - `nimbus` closure is unchanged: build the `nimbus` system before and after the change and run
    `nix store diff-closures <before> <after>`; expect no package added or removed.
  - `bea` and `truce`: `nix store diff-closures` shows only additions (compose, lazydocker; for
    `truce` also Docker and its dependencies), no removals.

## Decisions
| Decision | Reason | Decision record? |
|----------|--------|------------------|
| Docker, not Podman, for now | A switch makes existing Docker images and volumes invisible; it needs its own migration plan | yes – `0001-docker-as-container-engine` (written at Close) |
| Engine in the base, tools in the `dev` role | Containers are standard on every host; the tools are development tools | no |
| `virtualisation.containers.enable` in the base | One standard setup; harmless for Docker, needed by Podman, Buildah and Skopeo | no |
| btrfs storage driver in the base | All hosts use the shared btrfs disk layout; a host with another layout overrides it | no – comment in code |

## Not in scope
- Podman, or any migration of Docker images and volumes.
- The JetBrains IDE (separate backlog item).
- The user's `docker` group membership (part of the user account, backlog item on the user
  account).

## Test plan
- **Existing tests that must still pass**: `just verify` (alejandra, statix, deadnix,
  `nix flake check`); `just build HOST` for `nimbus`, `bea` and `truce`.
- **New tests**: the `nix eval` and `nix store diff-closures` checks in Steps 1 and 2.
- **Real host** (operator, after approval of a switch): `truce` first. Check:
  - `systemctl is-active docker` → `active`
  - `docker run --rm hello-world` works
  - `id` shows the `docker` group; if not, `docker` needs `sudo` on `truce` – note it for the
    user account item.

## Compatibility and performance
- `nimbus`: no change in the built system.
- `bea`: new `/etc/containers` files and two terminal tools.
- `truce`: new Docker service that starts at boot, with a `docker0` bridge and its own firewall
  rules (firewall stays on); new `/etc/containers` files and two tools. A little more memory use
  and boot time on an old laptop.
- No data moves; `/var/lib/docker` on `nimbus` and `bea` stays as it is.

## Progress
- [x] Step 1
- [x] Step 2
- [x] All checks pass

## Deviations
None.

## Review findings
