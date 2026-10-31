# 0003 – zswap in front of the swap file

**Status**: valid
**Date**: 2026-10-31
**Change**: Swap and memory pressure on all hosts (change documents in git history)

## Context
All hosts have an 8 GB swap file on LUKS and btrfs (shared disk layout). Only `nimbus` used zswap,
with one wrong parameter name and one parameter that kernel 6.18 no longer has. `vm.swappiness` was
1 on all hosts. On `bea` this evicted file cache: about 22 GB was read again in 2 hours 21 minutes,
about 35 times more than the swapped pages that were read back.

## Decision
zswap on all hosts with the NixOS module `boot.zswap` (zstd, pool of 25%, shrinker on), in front of
the swap file. `vm.swappiness` is 60. `systemd-oomd` watches user sessions on graphical hosts. The
disk layout does not change.

## Options considered
| Option | For | Against |
|--------|-----|---------|
| zswap + swap file | Oldest pages move to disk; uses the swap file that exists; fewer disk writes | Needs a swap device |
| zram only | No disk writes | No overflow; the swap file is not used; writeback needs a block device, not a file on btrfs |
| zram + swap file | Common setup | Old pages stay in zram while newer pages go to disk |
| Plain kernel parameters for zswap | No change to the initrd | Applies only after a reboot; no checks against zram or a missing swap device |

## Consequences
- `boot.zswap` still sets `zpool`, which kernel 6.18 does not have. One sysfs unit waits and never
  runs; this is harmless, and newer nixpkgs removes it.
- zswap and zram cannot be on together; the module fails at evaluation.
- `systemd-oomd` can stop any program in a user session. If it stops the desktop session, set
  `systemd.oomd.enableUserSlices` to false.
- Docker containers are in `system.slice`, so `systemd-oomd` does not stop them. A leaking container
  can still cause a user program to be stopped; give such a container a memory limit.
- After a week of normal use, compare `workingset_refault_file` and `workingset_refault_anon` in
  `/proc/vmstat`. If file rereads are still much higher, try swappiness 100.
