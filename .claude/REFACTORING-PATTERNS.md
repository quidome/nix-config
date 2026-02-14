# NixOS Refactoring Patterns

Common refactoring patterns for this repository, aligned with the code style guide.

## Pattern 1: Extract Duplicate Package Lists

### Before (in multiple modules)
```nix
# nixos/desktop/plasma/default.nix
environment.systemPackages = with pkgs; [
  kate
  konsole
  okular
];

# home/desktop/plasma/default.nix
home.packages = with pkgs; [
  kate
  okular
];
```

### After
```nix
# shared/packages.nix (new file)
{ lib, ... }:
{
  options.settings.packages = {
    plasma.common = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = "Common Plasma packages";
    };
  };

  config.settings.packages.plasma.common = with pkgs; [
    kate
    okular
  ];
}

# nixos/desktop/plasma/default.nix
environment.systemPackages = config.settings.packages.plasma.common ++ (with pkgs; [
  konsole  # system-only package
]);

# home/desktop/plasma/default.nix
home.packages = config.settings.packages.plasma.common;
```

## Pattern 2: Use Settings System Instead of Hardcoding

### Before
```nix
# Multiple modules with hardcoded font
programs.alacritty.settings.font = {
  normal.family = "FiraCode Nerd Font";
  size = 12;
};

programs.kitty.settings = {
  font_family = "FiraCode Nerd Font";
  font_size = 12;
};
```

### After
```nix
# Already exists: home/settings.nix defines terminalFont
# Use it consistently:

programs.alacritty.settings.font = {
  normal.family = config.settings.terminalFont.name;
  size = config.settings.terminalFont.size;
};

programs.kitty.settings = {
  font_family = config.settings.terminalFont.name;
  font_size = config.settings.terminalFont.size;
};
```

## Pattern 3: Module Organization (Too Large)

### Before (300+ line module)
```nix
# nixos/desktop/gnome/default.nix
{ config, lib, pkgs, ... }:
{
  # 50 lines of options
  options = { ... };

  # 200 lines of config
  config = {
    # environment settings
    # services
    # programs
    # extensions
    # keybindings
  };
}
```

### After (split into multiple modules)
```nix
# nixos/desktop/gnome/default.nix
{ ... }:
{
  imports = [
    ./extensions.nix
    ./keybindings.nix
    ./programs.nix
    ./services.nix
  ];

  # Core options and config only (50 lines)
}

# nixos/desktop/gnome/extensions.nix
# nixos/desktop/gnome/keybindings.nix
# etc.
```

## Pattern 4: Proper Conditional Configuration

### Before
```nix
config = {
  services.xserver = if config.settings.gui == "plasma" then {
    enable = true;
    displayManager.sddm.enable = true;
  } else {};
};
```

### After
```nix
config = lib.mkIf (config.settings.gui == "plasma") {
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
  };
};
```

## Pattern 5: Use mkDefault for Overridable Defaults

### Before
```nix
config = {
  settings.terminalFont.name = "FiraCode Nerd Font";
  settings.terminalFont.size = 12;
};
```

### After
```nix
config = {
  settings.terminalFont.name = lib.mkDefault "FiraCode Nerd Font";
  settings.terminalFont.size = lib.mkDefault 12;
};
```

## Pattern 6: Consistent Import Ordering

### Before
```nix
{ config, ... }:
{ pkgs, lib, ... }:
```

### After
```nix
{ config, lib, pkgs, ... }:
```

Always alphabetical: config, lib, pkgs, then any others.

## Pattern 7: Extract Common Let Bindings

### Before (in multiple modules)
```nix
# Multiple places
let
  cfg = config.programs.myapp;
in

let
  cfg = config.programs.myapp;
in
```

### After
```nix
# If truly shared, consider extracting to shared/
# Otherwise, ensure consistent naming across modules
let
  cfg = config.programs.myapp;  # Consistent pattern
in
```

## Pattern 8: Proper Option Definitions

### Before
```nix
options.myOption = lib.mkEnableOption "my feature";
```

### After
```nix
options.myOption = lib.mkOption {
  type = lib.types.bool;
  default = false;
  description = lib.mdDoc "Enable my feature";
  example = true;
};
```

## Pattern 9: Centralize Authorization Keys

### Before (scattered across host configs)
```nix
# Multiple hosts repeating the same keys
users.users.myuser.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA..."
];
```

### After
```nix
# Already using shared/settings.nix:
# config.settings.authorizedKeys is defined globally

users.users.myuser.openssh.authorizedKeys.keys =
  config.settings.authorizedKeys;
```

## Pattern 10: Desktop-Specific Settings with Derived Values

### Before
```nix
# Repeated checks across modules
config = lib.mkIf (config.settings.gui == "niri") {
  # niri config
};
```

### After
```nix
# shared/settings.nix already has:
# config.settings.desktop.niri.enable = config.settings.gui == "niri";

# Use the derived setting:
config = lib.mkIf config.settings.desktop.niri.enable {
  # niri config
};
```

## Anti-Patterns to Avoid

### Don't Use if-then-else for Configuration
```nix
# BAD
services.foo.enable = if condition then true else false;

# GOOD
services.foo.enable = lib.mkIf condition true;
# or simply
services.foo.enable = condition;
```

### Don't Nest with Statements
```nix
# BAD
with lib; with pkgs; with config; [ ... ]

# GOOD
with lib;
with pkgs;
[ ... ]
```

### Don't Put Everything in One Module
- Modules > 300 lines should be split
- Separate concerns (programs, services, UI, etc.)
- Use default.nix to aggregate imports

### Don't Hardcode Values That Vary
- Use the settings system for values that differ per host/user
- Extract to shared/ for truly common values
- Consider host-specific vars.nix for host-unique values (encrypted)

## Validation Checklist

After refactoring, always check:
- [ ] `nix flake check` passes
- [ ] `just check-all` succeeds
- [ ] No encrypted files modified
- [ ] Imports are alphabetically ordered
- [ ] Proper indentation (2 spaces)
- [ ] `mkIf` used for conditionals
- [ ] `mkDefault` used for defaults
- [ ] No duplicate code introduced
- [ ] Settings system used consistently
- [ ] Module responsibilities clear
