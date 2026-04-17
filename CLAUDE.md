# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A **Nix flake library** — it exports builder functions and shared modules for workstations and servers. It does not define any machines itself; other flakes consume it as an input.

## Development Commands

```bash
nix develop          # Enter dev shell (installs pre-commit hooks)
nix flake check      # Run checks: nixfmt, deadnix, flake-checker
```

Pre-commit hooks run nixfmt, deadnix, and flake-checker automatically. Run `nix flake check` to validate before committing.

## Architecture

### Exported API (`flake.nix` → `lib/builders.nix`)

Three builder functions are exported under `lib`:

| Builder | Target | Notes |
|---|---|---|
| `mkNixosWorkstation` | NixOS desktop/laptop | Supports `wslMachine = true` for WSL |
| `mkDarwinWorkstation` | macOS (nix-darwin) | Includes Homebrew + Rosetta |
| `mkNixosServer` | Headless NixOS | No Home Manager |

All builders expect the consuming flake to have host files at:
```
hosts/workstations/<hostname>/configuration.nix
hosts/workstations/<hostname>/home.nix
hosts/servers/<hostname>/configuration.nix
```

### Module Layer Order

Config is applied in this order (later layers override earlier):

1. `shared/base/default.nix` — Nix settings, SSH, minimal packages (all systems)
2. `shared/base/nixos.nix` — SSH hardening (NixOS only)
3. `shared/workstations/all/default.nix` + `packages.nix` — Cross-platform packages
4. `shared/workstations/<platform>/default.nix` — Platform-specific system config
5. Home Manager modules in same order (all → platform → host-specific)
6. Consuming flake's host files — host-specific overrides (highest priority)

### Platform Split

- `shared/workstations/all/` — Shared across NixOS, Darwin, WSL (shell, git, tmux, k8s, terraform tools)
- `shared/workstations/nixos/` — NixOS desktop: display server, audio, Docker, GNOME, Sway
- `shared/workstations/darwin/` — macOS: nix-darwin, Homebrew, Dock config
- `shared/workstations/wsl/` — WSL: lightweight overrides only

### Key Design Patterns

- Platform differences are isolated to platform-specific directories; `all/` must remain cross-platform
- `homeDirectory` is set per-platform in each `home.nix` (`/home/<user>` vs `/Users/<user>`)
- Packages go in `packages.nix` files; program configuration goes in `home.nix`
- The `flakeDir` parameter (set to `self` by consumers) allows builders to locate host files via `"${flakeDir}/hosts/..."` paths

### Flake Inputs

Key inputs passed through to consumers via `follows`:
- `nixpkgs` (unstable), `nixpkgs-darwin`
- `home-manager` (master)
- `nix-darwin`, `nixos-wsl`, `nixos-hardware`
- `nix-homebrew`, `pre-commit-hooks`
- `nixcats-config` (Neovim), `llm-agents` (Claude Code, Codex)

Cachix substituters configured: `nix-community`, `cache.numtide.com`

### Supported Systems

`x86_64-linux` and `aarch64-darwin` only.
