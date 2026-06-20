# nix-entry-plug

> _"The entry plug is the pilot's interface to the Evangelion. This repository is your interface to your machines."_

Personal NixOS + home-manager flake. Hyprland on Wayland, Stylix theming, sops-nix for secrets, Disko for disks, Limine for boot.

## Stack

- **Boot:** Limine (primary) + systemd-boot (specialisation fallback)
- **Disks:** Disko, BTRFS with subvolumes (`@`, `@home`, `@nix`, `@log`, `@snapshots`, `@persist`)
- **Kernel:** `linuxPackages_zen`, AMD microcode + AMDGPU
- **Desktop:** Hyprland, greetd + ReGreet, waybar, rofi, mako, hyprlock, hypridle, hyprshade
- **Theming:** Stylix (Rosé Pine, dark), JetBrains Mono Nerd Font, Bibata cursors, Papirus icons
- **Shell:** fish + starship + atuin, abundant abbreviations
- **Editors:** Zed (GUI), Neovim (TUI)
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
just test        # build and activate without adding to boot menu
just boot        # install for next boot only (won't activate now)
just check       # nix flake check + statix + deadnix
just build       # build the full host toplevel (no activation)
just fmt         # treefmt the tree
just update      # update flake inputs and switch
just diff        # nvd diff booted ↔ current
just gc          # nh clean all --keep 5 --keep-since 7d
```

See [`docs/recovery.md`](./docs/recovery.md) when something goes wrong.

## Install

Fresh install? See [`docs/install-guide.md`](./docs/install-guide.md). TL;DR (from a NixOS minimal ISO with flakes enabled and the repo cloned):

```sh
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- \
  --mode disko --flake .#unit-01
sudo nixos-install --flake .#unit-01 --no-root-passwd
```
