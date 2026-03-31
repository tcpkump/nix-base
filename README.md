# nix-base

Shared Nix flake providing reusable modules and builder functions for NixOS and macOS (nix-darwin) workstation and
server configurations.

This flake is a **library** — it does not define any machines itself. Other flakes consume it as an input and call its
builder functions to produce system configurations.

## What's included

- **`lib`** — Builder functions exported as flake outputs:
  - `mkNixosWorkstation` — NixOS workstation with Home Manager
  - `mkDarwinWorkstation` — macOS workstation with nix-darwin + Home Manager + Homebrew
  - `mkNixosServer` — Minimal NixOS server (no Home Manager)
- **`shared/base/`** — Common Nix settings applied to all systems (nix config, openssh, etc.)
- **`shared/workstations/all/`** — Cross-platform workstation config: shell, git, tmux, k9s, CLI tools, packages
- **`shared/workstations/nixos/`** — NixOS-specific: display, audio, Bluetooth, GNOME, Sway
- **`shared/workstations/darwin/`** — macOS-specific: Homebrew, Dock, nix-darwin options (assumes [Determinate Nix](https://determinate.systems/nix/))
- **`shared/workstations/wsl/`** — WSL-specific overrides

## Using this flake

Add nix-base as an input and follow its nixpkgs to keep lockfiles in sync:

```nix
inputs = {
  nix-base.url = "github:tcpkump/nix-base";
  nixpkgs.follows = "nix-base/nixpkgs";
  home-manager.follows = "nix-base/home-manager";
  # follow other inputs as needed...
};
```

Call a builder in your outputs:

```nix
outputs = inputs@{ self, nix-base, nixos-hardware, ... }: {
  nixosConfigurations.my-laptop = nix-base.lib.mkNixosWorkstation {
    inherit inputs;
    flakeDir = self;          # your flake's self, for resolving host files
    hostname = "my-laptop";   # expects hosts/workstations/my-laptop/{configuration,home}.nix
    system = "x86_64-linux";
    user = "alice";
    modules = [ nixos-hardware.nixosModules.framework-13-7040-amd ];  # optional extras
  };
};
```

### Builder parameters

| Parameter | Type | Description |
|---|---|---|
| `flakeDir` | path | `self` from the consuming flake — used to locate `hosts/` |
| `hostname` | string | Must match a directory under `hosts/workstations/` or `hosts/servers/` |
| `system` | string | e.g. `"x86_64-linux"`, `"aarch64-darwin"` |
| `user` | string | Primary user name |
| `modules` | list | Extra NixOS/Darwin modules to include |
| `extraUserModules` | list | Extra Home Manager modules for the user |
| `wslMachine` | bool | Enable WSL-specific config (NixOS only) |

### Expected host file layout

Each consuming flake must provide these files for each host:

```
hosts/
└── workstations/
    └── <hostname>/
        ├── configuration.nix   # system config (imports hardware, desktop, etc.)
        └── home.nix            # Home Manager config (packages, dotfiles, git, etc.)
```

For servers:
```
hosts/
└── servers/
    └── <hostname>/
        └── configuration.nix
```

## Development

```bash
# Enter dev shell with pre-commit hooks
nix develop

# Run checks (nixfmt, flake-checker, deadnix)
nix flake check
```
