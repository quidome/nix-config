# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a flake-based NixOS configuration repository managing multiple hosts with home-manager integration. The configuration uses a centralized approach where NixOS and home-manager configurations are defined together in the flake.

## Common Commands

### System Management
```bash
# Build and switch NixOS configuration
just build
# or manually:
sudo nixos-rebuild --flake . switch

# Build for boot (doesn't activate immediately)
just rebuild-boot
# or:
sudo nixos-rebuild --flake . boot

# Build specific host configuration
nixos-rebuild --flake .#<hostname> build

# Build all host configurations
just build-all

# Check all configurations (dry run)
just check-all
```

### Updates and Maintenance
```bash
# Update flake.lock and nix-index cache
just update

# Garbage collection
just gc

# Complete update, GC, and build cycle
just all

# Pull latest changes, GC, and build
just pull-gc-build

# Validate flake syntax
nix flake check
```

### Live Image Building
```bash
# Build base ISO
nix build .#nixosConfigurations.baseIso.config.system.build.isoImage

# Build bcachefs ISO
nix build .#nixosConfigurations.bcachefsIso.config.system.build.isoImage

# ISO output location: result/iso/
```

### Remote Installation
```bash
# Install NixOS remotely using nixos-anywhere
nix run github:nix-community/nixos-anywhere -- \
  --flake .#${TARGET_HOST} \
  --generate-hardware-config nixos-generate-config hosts/${TARGET_HOST}/hardware-configuration.nix \
  --target-host root@${TARGET_HOST_IP}
```

## Architecture

### Flake Structure

The flake.nix uses a `mkHost` function that creates NixOS systems with integrated home-manager. Each host configuration automatically includes:
- Disko module for declarative disk management
- Shared modules from `./shared`
- NixOS modules from `./nixos`
- Host-specific configuration from `./hosts/${host}/configuration.nix`
- Home-manager configuration from `./hosts/${host}/home.nix`

**Key Details:**
- Home-manager runs as a NixOS module (not standalone)
- All configurations inherit from `./shared` which provides common settings
- The flake uses nixpkgs 25.11 (stable) and nixpkgs-unstable via overlay
- Unstable packages accessible via `pkgs.unstable.<package>`

### Directory Structure

```
.
├── flake.nix                # Main entry point with mkHost function
├── shared/                  # Common settings shared by NixOS and home-manager
│   ├── settings.nix        # Global options (gui, preferQt, authorizedKeys)
│   └── secrets.nix         # Encrypted secrets (git-crypt)
├── nixos/                   # System-level NixOS modules
│   ├── desktop/            # Desktop environment configs (cosmic, gnome, hyprland, niri, plasma, sway)
│   ├── profiles/           # System profiles (common, workstation)
│   └── services/           # System services
├── home/                    # User-level home-manager modules
│   ├── desktop/            # Desktop-specific home configs
│   ├── profiles/           # User profiles (common, workstation)
│   ├── programs/           # Application configurations
│   ├── services/           # User services
│   └── settings.nix        # User settings (terminalFont)
├── hosts/                   # Host-specific configurations
│   └── ${hostname}/
│       ├── configuration.nix       # NixOS config
│       ├── home.nix               # home-manager config
│       ├── disk-config.nix        # Disko configuration
│       ├── hardware-configuration.nix  # Hardware (encrypted)
│       ├── vars.nix               # Host variables (encrypted)
│       ├── home-vars.nix          # User variables (encrypted)
│       └── shared.nix             # Shared host settings
└── live-image/             # Live ISO configurations
```

### Settings System

The repository uses a custom settings system defined in `shared/settings.nix` and `home/settings.nix`:

**Global Settings** (`config.settings.*`):
- `gui`: Which desktop environment to use (none, cosmic, gnome, hyprland, niri, plasma, sway)
- `preferQt`: Whether to prefer Qt over GTK (auto-set for plasma)
- `authorizedKeys`: SSH public keys for all hosts
- `desktop.niri.enable`: Automatically set based on gui choice

**Home Settings** (`config.settings.*`):
- `terminal`: Which terminal emulator to use (defaults: niri→ghostty, others→wezterm)
- `terminalFont.name`: Font for graphical terminals
- `terminalFont.size`: Font size for terminals

These settings are accessible in both NixOS and home-manager modules, allowing centralized configuration decisions to influence both system and user setups.

### Module Import Pattern

All module directories use `default.nix` to aggregate imports:
- `nixos/default.nix` imports all NixOS-level modules
- `home/default.nix` imports all home-manager modules
- Each host's configuration imports its specific files plus shared modules

## Security - CRITICAL

**NEVER read, access, or display content from files listed in `.gitattributes`**

These files are encrypted with git-crypt and contain:
- Hardware configurations with disk layouts
- Host-specific variables including user accounts/passwords
- SSH settings and personal git configuration
- API keys, passwords, and certificates

**Encrypted files:**
- `hardware-configuration.nix`
- `home-vars.nix`
- `secrets.nix`
- `system-vars.nix`
- `vars.nix`

Before any repository analysis, verify encryption status:
```bash
git-crypt status
just check-secrets
```

If you accidentally access encrypted content, immediately stop and advise rotating all secrets.

## Code Style

- Use 2-space indentation
- Imports alphabetically ordered at top of files
- Use `with lib;` for library functions, `with pkgs;` for packages
- Package lists: `with pkgs; [ package1 package2 ]`
- Options defined with `mkOption` and appropriate types
- Format with `alejandra` (though not currently enforced)
- Follow existing module structure: options → config → implementation
- Use `mkIf` for conditional configuration
- Use `lib.mkDefault` for overridable defaults

## Hosts

Current hosts: `bea`, `coolding`, `nimbus`, `truce`

Each host has its own configuration in `hosts/${hostname}/` including:
- NixOS system configuration
- home-manager user configuration
- Disko disk layout
- Hardware-specific settings (encrypted)
- Host-specific variables (encrypted)
