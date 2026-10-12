# 0001 – Docker as container engine

**Status**: valid
**Date**: 2026-10-11
**Change**: Containers standard on every host (change documents in git history)

## Context
Containers became part of the always-on system base, so every host has them. Before, only
`nimbus` and `bea` had Docker, set up in their own host files. One engine had to be chosen for
the shared base.

## Decision
Docker, with the btrfs storage driver, for now. The shared container configuration
(`/etc/containers`) is also on, so tools such as Podman, Buildah and Skopeo can work if they are
added later.

## Options considered
| Option | For | Against |
|--------|-----|---------|
| Docker | Already used on `nimbus` and `bea`; no migration; `docker-compose` and `lazydocker` work as now | Needs a daemon that runs as root; the user needs the `docker` group |
| Podman with Docker compatibility | Rootless, no daemon, no group needed | Existing Docker images and volumes are not visible to Podman; some tools behave a little differently; not researched yet |

## Consequences
- The user's `docker` group membership stays part of the user account (encrypted host files).
- A switch to Podman is a separate change and needs a plan for existing images and volumes first
  (see the research line in `docs/ideas.md`).
- A host with a disk layout other than the shared btrfs layout must override the storage driver.
