# Common commands for nix-entry-plug.
# Run `just` (or `just list`) to see all targets.

set shell := ["bash", "-cu"]

# Default host for build / switch / test targets.
host := "unit-01"

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

# Build the host's top-level system without activating it. The most
# meaningful pre-install sanity check we have: forces every module to
# evaluate and every derivation to build, but doesn't touch the
# running system or require a VM.
build:
    nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel

# Format the whole tree with treefmt (via `nix fmt`).
fmt:
    nix fmt

# Update flake inputs, then switch.
update:
    nh os switch --hostname {{host}} --update

# Garbage collect: keep the last 5 generations and anything from the last 7 days.
gc:
    nh clean all --keep 5 --keep-since 7d

# Show the diff between current and booted generations.
diff:
    nvd diff /run/booted-system /run/current-system
