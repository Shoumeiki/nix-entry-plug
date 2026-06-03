# NixOS Desktop Build (Ellen)

Declarative NixOS desktop configuration using **flakes** + **Home Manager**, targeting an AMD gaming workstation with Hyprland.

 baseline for:

- Flake-based host build
- Home Manager integration
- Docker, gaming, and desktop module split
- `sops-nix` secrets wiring for user passwords + SSH authorized keys

## Layout

- `flake.nix` — flake entrypoint and inputs
- `hosts/desktop` — host-specific NixOS config
- `modules/nixos` — reusable NixOS modules
- `modules/home` — Home Manager modules for `ellen`
- `secrets` — sops-nix files (`secrets.yaml`, `.sops.yaml`)

## What is already wired

- `sops.defaultSopsFile` points at `secrets/secrets.yaml`
- Users read password hashes from secrets:
  - `users/ellen/password`
  - `users/guest/password`
- Ellen SSH authorized keys are read from:
  - `ssh/ellen-authorized-keys`
- OpenSSH is enabled with password SSH auth disabled
- Nix GC + `auto-optimise-store` are enabled

## Secrets setup guide (sops-nix + age)

> These steps are required before first successful switch.

### 1) Create an age key pair (on target machine)

```sh
mkdir -p ~/.config/sops/age
chmod 700 ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Get the public recipient (starts with `age1...`):

```sh
age-keygen -y ~/.config/sops/age/keys.txt
```

### 2) Set recipient in `secrets/.sops.yaml`

Replace the placeholder recipient with your real one:

```yaml
creation_rules:
  - path_regex: secrets\.yaml$
    age:
      - "age1...your-public-recipient..."
```

### 3) Create password hashes

Generate yescrypt hashes for NixOS user passwords:

```sh
mkpasswd -m yescrypt
```

Run once per user and copy each resulting hash.

### 4) Fill `secrets/secrets.yaml`

Replace placeholders in `secrets/secrets.yaml` with real values:

```yaml
users:
  ellen:
    password: "$y$j9T$..."
  guest:
    password: "$y$j9T$..."
ssh:
  ellen-authorized-keys: |
    ssh-ed25519 AAAA... ellen@host
```

For multiple keys, add one per line in the block value.

### 5) Encrypt the secrets file

```sh
sops -e -i secrets/secrets.yaml
```

### 6) Verify the file is encrypted

You should see SOPS metadata (`sops:` block) and encrypted values in the file.

### 7) Build and switch

```sh
nix flake update
nix flake check
sudo nixos-rebuild switch --flake .#desktop
```

## First boot checklist

- Fill hardware/disk config in `hosts/desktop/hardware.nix` (and Disko layout)
- Adjust monitor outputs in `modules/home/hyprland.nix` or move final monitor setup into `hosts/desktop/monitors.nix`
- Set real git identity in `modules/home/git.nix`

## Notes

- Hardware and disk details are intentionally placeholders in `hosts/desktop/hardware.nix` and should be filled for the target machine.
- Monitor layout is isolated in `hosts/desktop/monitors.nix` for portability.
- Home Manager is integrated as a NixOS module.
