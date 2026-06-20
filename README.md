# nix-entry-plug

> _"The entry plug is the pilot's interface to the Evangelion. This repository is your interface to your machines."_

Personal NixOS + home-manager flake. Hyprland on Wayland, Stylix theming, sops-nix for secrets, Disko for disks, Limine for boot.

## Hosts

| Host | Role | Status |
| --- | --- | --- |
| `unit-01` | AMD desktop (7800X3D / RX 7700 XT), gaming + dev | In progress |
| `unit-00` / `unit-02` / `unit-03` / `unit-12` | management / media / NAS / router | Planned |

## Stack

- **Boot:** Limine (primary) + systemd-boot (specialisation fallback)
- **Disks:** Disko, BTRFS with subvolumes (`@`, `@home`, `@nix`, `@log`, `@snapshots`, `@persist`)
- **Kernel:** `linuxPackages_zen`, AMD microcode + AMDGPU
- **Desktop:** Hyprland, greetd + ReGreet, waybar, rofi, mako, hyprlock, hypridle, hyprshade
- **Theming:** Stylix (Rosé Pine, dark), JetBrains Mono Nerd Font, Bibata cursors, Papirus icons
- **Shell:** fish + starship + atuin, abundant abbreviations
- **Editors:** Zed (GUI), Neovim + LazyVim (TUI)
- **Tooling:** nh, nom, nvd, nix-index + comma, just, direnv + nix-direnv
- **Quality:** nixfmt-rfc-style, statix, deadnix, treefmt-nix, pre-commit-hooks
- **Secrets:** sops-nix (age)

See [`docs/nix-entry-plug-spec.md`](./docs/nix-entry-plug-spec.md) for the full design and [`docs/nix-entry-plug-checklist.md`](./docs/nix-entry-plug-checklist.md) for the migration plan.

## Layout

```
flake.nix              # Inputs, hosts, specialArgs
hosts/<unit-XX>/       # Host-specific: hardware, disko, specialisations
modules/               # Reusable NixOS modules (core, hardware, desktop, gaming, options, secrets)
home/                  # home-manager (common + desktop + per-user)
overlays/              # Custom package overlays
lib/                   # Helper functions
secrets/               # sops-encrypted secrets
docs/                  # Spec, checklist, install + recovery guides
```

Modules in `modules/` are host-agnostic; anything host-specific lives in `hosts/`.

## Usage

```sh
just switch      # format, lint, then nh os switch
just test        # build without adding to boot menu
just check       # nix flake check + statix + deadnix
just fmt         # treefmt the tree
just update      # update flake inputs
just vm          # build and launch a VM
just gc          # garbage collect old generations
```

Common aliases (`rebuild`, `dry`, `gen-diff`, `clean`, ...) are listed in spec §6.

## Install

See `docs/install-guide.md` (Phase 6). TL;DR:

```sh
# from NixOS minimal ISO
git clone https://github.com/Shoumeiki/nix-entry-plug
cd nix-entry-plug
sudo nix --experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- --mode disko ./hosts/unit-01/disko.nix
sudo nixos-install --flake .#unit-01
```
