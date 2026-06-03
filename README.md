# NixOS Desktop Build (Ellen)

Declarative NixOS desktop configuration using **flakes** + **Home Manager**, targeting an AMD gaming workstation with Hyprland.

## Layout

- `flake.nix` — flake entrypoint and inputs
- `hosts/desktop` — host-specific NixOS config
- `modules/nixos` — reusable NixOS modules
- `modules/home` — Home Manager modules for `ellen`
- `secrets` — sops-nix files (`secrets.yaml`, `.sops.yaml`)

## Quick start

1. Create/update encrypted secrets:
   - `secrets/secrets.yaml`
   - `secrets/.sops.yaml`
2. Generate `flake.lock`:
   - `nix flake update`
3. Build/check host:
   - `nix flake check`
   - `sudo nixos-rebuild switch --flake .#desktop`

## Notes

- Hardware and disk details are intentionally placeholders in `hosts/desktop/hardware.nix` and should be filled for the target machine.
- Monitor layout is isolated in `hosts/desktop/monitors.nix` for portability.
- Home Manager is integrated as a NixOS module.
