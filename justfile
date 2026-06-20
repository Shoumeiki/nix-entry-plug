# Common commands for nix-entry-plug.
# Run `just` (or `just list`) to see all targets.

set shell := ["bash", "-cu"]

# Default host for vm / switch / test targets.
host := "unit-01"

# QEMU display backend. SDL is the most reliable choice from inside a Nix
# dev shell — the default `gtk` backend often fails to initialise because
# fontconfig isn't wired up. Override with `QEMU_OPTS="-display gtk" just vm`
# or run from a shell outside `nix develop`.
qemu_opts := env_var_or_default("QEMU_OPTS", "-display sdl")

# Show available targets.
default:
    @just --list

# Apply the current flake to the running system.
# Formats and lints first so a broken commit is caught before activation.
switch: fmt check
    nh os switch --hostname {{host}}

# Apply to next boot only (won't activate now).
boot:
    nh os boot --hostname {{host}}

# Build and activate, but don't add to boot menu.
test:
    nh os test --hostname {{host}}

# Show what would change without applying.
dry:
    nh os switch --hostname {{host}} --dry

# Validate the flake and run all linters.
check:
    nix flake check
    statix check .
    deadnix --fail .

# Format the whole tree with treefmt (via `nix fmt`).
fmt:
    nix fmt

# Update flake inputs, then switch.
update:
    nh os switch --hostname {{host}} --update

# Build and launch a VM of the given host (default: unit-01).
# Boots through the full bootloader stack (Limine) so you can verify
# specialisations appear in the menu.
vm:
    nixos-rebuild build-vm-with-bootloader --flake .#{{host}}
    QEMU_OPTS="{{qemu_opts}}" ./result/bin/run-{{host}}-vm

# Headless VM: skips the bootloader and boots the kernel directly into a
# text console on stdio. Use this when graphics aren't available or when
# you only need to check boot / login / networking.
vm-headless:
    nixos-rebuild build-vm --flake .#{{host}}
    QEMU_OPTS="-nographic" ./result/bin/run-{{host}}-vm

# Garbage collect: keep the last 5 generations and anything from the last 7 days.
gc:
    nh clean all --keep 5 --keep-since 7d

# Show the diff between current and booted generations.
diff:
    nvd diff /run/booted-system /run/current-system
