# NixOS Configuration Improvements

This document outlines potential improvements for this NixOS configuration.

## Security Improvements

### 1. MongoDB Network Binding

**Current Issue:** In `modules/mongodb.nix:13`, MongoDB binds to `0.0.0.0`, exposing it to all network interfaces.

**Fix:** Unless you need remote access, bind to localhost only:
```nix
bind_ip = "127.0.0.1";  # or remove this line to use the default
```

### 2. Add .gitignore

**Current Issue:** Missing `.gitignore` file to prevent accidentally committing sensitive files.

**Fix:** Create `.gitignore`:
```gitignore
# Build results
result
result-*

# Hardware configs (contain UUIDs)
# Uncomment if you don't want to commit these
# hosts/*/hardware-configuration.nix

# Editor directories
.vscode/
.idea/

# Secrets (belt-and-suspenders)
*_password
password_hash
*.key
*.pem

# OS files
.DS_Store
```

### 3. Secrets Management

**Current Issue:** Plain text password files in `/persist` could be more secure.

**Recommendation:** Consider using `agenix` or `sops-nix` instead of plain text password files. This encrypts secrets and allows them to be safely committed to git.

**Example with agenix:**
```nix
# Add to flake inputs
agenix.url = "github:ryantm/agenix";

# Use in modules
age.secrets.mongodb-password = {
  file = ./secrets/mongodb-password.age;
  owner = "mongodb";
};
```

### 4. Document Firewall Ports

**Current Issue:** In `hosts/darter-pro/configuration.nix:65-66`, unclear what ports are used for.

**Fix:** Add comments explaining each port:
```nix
networking.firewall.allowedTCPPorts = [
  443   # nginx (n8n)
  7236  # ???
  7250  # ???
];
```

## Performance Improvements

### 5. Add Automatic Garbage Collection

**Recommendation:** Configure automatic cleanup of old generations to save disk space.

**Implementation:** Add to a common module:
```nix
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};

nix.optimise = {
  automatic = true;
  dates = [ "weekly" ];
};
```

### 6. Enable zram for Better Memory Management

**Recommendation:** Add zram swap for better memory performance, especially on laptops.

**Implementation:**
```nix
zramSwap = {
  enable = true;
  algorithm = "zstd";
  memoryPercent = 50;
};
```

### 7. Enable Flake Auto-Update

**Recommendation:** Add a systemd timer to keep your system up-to-date automatically or send reminders.

**Implementation:**
```nix
systemd.timers.nixos-upgrade = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnCalendar = "weekly";
    Persistent = true;
  };
};

systemd.services.nixos-upgrade = {
  script = ''
    cd /home/${username}/.dotfiles
    ${pkgs.nix}/bin/nix flake update
    # Send notification about updates available
  '';
  serviceConfig = {
    Type = "oneshot";
    User = username;
  };
};
```

## Code Quality & Maintainability

### 8. Remove Commented Code

**Current Issue:** Several files contain commented-out code that should be removed or uncommented.

**Locations:**
- `home/home.nix:62-64` (commented .config sources)
- `desktops/qtile.nix:9-14` (old qtile config)

**Action:** Either remove or uncomment these sections.

### 9. Extract Common Persistence Patterns

**Recommendation:** Create helper functions for persistence entries to reduce repetition.

**Implementation:**
```nix
# lib/persistence.nix
{ username }: {
  mkUserDirs = dirs: map (dir:
    if builtins.isString dir
    then dir
    else dir
  ) dirs;

  mkUserFiles = files: map (file:
    if builtins.isString file
    then file
    else file
  ) files;
}
```

### 10. Add Flake Checks

**Recommendation:** Add validation to ensure configurations are valid before deployment.

**Implementation:** Add to `flake.nix`:
```nix
outputs = { nixpkgs, ... } @ inputs: {
  # ... existing configs ...

  checks = builtins.mapAttrs (system: deployments:
    builtins.mapAttrs (name: deployment: deployment.config.system.build.toplevel) deployments
  ) self.nixosConfigurations;
};
```

Then run: `nix flake check`

## Backup & Recovery

### 11. Backup Strategy for /persist

**Current Issue:** No automated backups for persistent data.

**Recommendation:** Add automated backups using btrbk or similar.

**Implementation:**
```nix
services.btrbk = {
  instances.persist = {
    onCalendar = "daily";
    settings = {
      snapshot_preserve = "14d";
      snapshot_preserve_min = "2d";
      target_preserve = "20d 10w *m";

      volume."/persist" = {
        subvolume = ".";
        snapshot_dir = ".snapshots";
      };
    };
  };
};

# Add to persist.nix
environment.persistence."/persist" = {
  directories = [
    # ... existing ...
    "/var/lib/btrbk"
  ];
};
```

### 12. Monitor Failed Services

**Recommendation:** Get notified when critical systemd services fail (especially n8n, mongodb).

**Implementation:**
```nix
systemd.services.notify-failed = {
  description = "Notify on failed services";
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.bash}/bin/bash -c 'systemctl --failed | ${pkgs.curl}/bin/curl -d @- https://ntfy.sh/your-topic'";
  };
};

systemd.timers.notify-failed = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnCalendar = "hourly";
    Persistent = true;
  };
};
```

## Development Experience

### 13. Add direnv Support

**Recommendation:** Enable direnv for automatic development environment loading.

**Implementation:**
```nix
# Add to home/home.nix or modules/development.nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};

# Then create .envrc in project directories:
# use flake
```

### 14. Create a Justfile or Makefile

**Recommendation:** Add a `justfile` for common operations to simplify workflows.

**Implementation:** Create `justfile`:
```justfile
# List available commands
default:
    @just --list

# Rebuild system for specified host
rebuild HOST:
    sudo nixos-rebuild switch --flake .#{{HOST}}

# Test configuration without switching
test HOST:
    sudo nixos-rebuild test --flake .#{{HOST}}

# Update flake inputs
update:
    nix flake update

# Update specific input
update-input INPUT:
    nix flake lock --update-input {{INPUT}}

# Check flake validity
check:
    nix flake check

# Format nix files
format:
    fd -e nix -x nixpkgs-fmt

# Show flake info
info:
    nix flake show
```

### 15. Add Build Time Optimization

**Recommendation:** Optimize Nix build settings for better performance.

**Implementation:**
```nix
nix.settings = {
  experimental-features = [ "nix-command" "flakes" ];
  auto-optimise-store = true;
  max-jobs = "auto";
  cores = 0;  # Use all cores for builds
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
};
```

## Documentation

### 16. Document watcher.sh

**Current Issue:** `watcher.sh` purpose is unclear.

**Action:** Add a comment at the top explaining what it does and when to use it.

### 17. Add Comments to Complex Logic

**Current Issue:** The impermanence rollback logic in `modules/impermanence.nix:4-41` is complex.

**Action:** Add more inline comments explaining:
- Hibernation detection mechanism
- Why SWSP signature is checked
- Cleanup logic for old roots
- When rollback is skipped

## Nice-to-Haves

### 18. Home Manager as Standalone

**Recommendation:** Make home-manager usable on non-NixOS systems.

**Implementation:** Add to `flake.nix`:
```nix
outputs = { nixpkgs, home-manager, ... } @ inputs: {
  # ... existing nixosConfigurations ...

  homeConfigurations = {
    "${username}" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs username; hostname = ""; };
      modules = [ ./home/home.nix ];
    };
  };
};
```

### 19. Add Pre-commit Hooks

**Recommendation:** Use `pre-commit-hooks.nix` to enforce formatting and prevent committing secrets.

**Implementation:**
```nix
# Add to flake inputs
pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

# Add to flake outputs
checks = {
  pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      nixpkgs-fmt.enable = true;
      statix.enable = true;
      deadnix.enable = true;
      # Prevent committing secrets
      detect-secrets.enable = true;
    };
  };
};
```

### 20. Modularize Qtile Config Further

**Current Status:** Qtile config is already well-modularized.

**Recommendation:** Consider adding a `modules/theme.py` separate from `get_theme.py` for theme definitions to keep theming logic separate from theme loading.

## Priority Recommendations

If implementing all improvements at once is overwhelming, prioritize these:

1. **High Priority:**
   - Add `.gitignore` (Security)
   - Fix MongoDB binding (Security)
   - Add automatic garbage collection (Performance/Disk Space)
   - Document firewall ports (Maintainability)

2. **Medium Priority:**
   - Add secrets management with agenix/sops-nix
   - Create justfile for common commands
   - Add backup strategy for /persist
   - Enable direnv

3. **Low Priority:**
   - Add flake checks
   - Monitor failed services
   - Extract persistence helpers
   - Add pre-commit hooks
