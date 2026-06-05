# NixOS Desktop Build (Ellen)

Declarative NixOS desktop configuration using **flakes** + **Home Manager**,
targeting an AMD gaming workstation (Ryzen 7 7800X3D / RX 7700 XT) with Hyprland.

Scaffolded from `documents/NixOS_Desktop_Build_Spec.md`.

---

## Repository layout

```
flake.nix                     Flake entrypoint and all inputs
hosts/desktop/
  default.nix                 Host entry point (imports all modules)
  hardware.nix                Disko layout, boot, GPU, Bluetooth
  monitors.nix                Reserved for host-level display overrides
modules/nixos/
  desktop.nix                 Hyprland, SDDM, PipeWire, XDG portals, fonts
  gaming.nix                  Steam, Proton-GE, GameMode, MangoHud, Gamescope
  networking.nix              nftables firewall, SSH, Mullvad VPN toggle
  users.nix                   ellen + guest accounts, sops-nix auth
  docker.nix                  Docker with auto-prune
modules/home/
  default.nix                 Home Manager entry point, XDG user dirs
  hyprland.nix                Full compositor config, keybinds, hyprlock, hypridle
  theming.nix                 Catppuccin Mocha, GTK, Qt/Kvantum, fonts
  terminal.nix                Foot (server/client mode)
  shell.nix                   Fish, Starship, zoxide, fzf, bat, eza, CLI tools
  editors.nix                 Neovim (LazyVim-ready) + Zed
  apps.nix                    mpv, browsers, Signal, Discord, Obsidian, etc.
  media.nix                   MPD + ncmpcpp, OBS Studio, Tenacity
  git.nix                     Git, delta diffs, gh CLI
secrets/
  secrets.yaml                sops-encrypted secrets (passwords, SSH keys)
  .sops.yaml                  sops age recipient config
```

---

## What is already wired

- Flake inputs: nixpkgs-unstable, home-manager, sops-nix, disko, catppuccin (Chaotic Nyx / CachyOS kernel commented out — uncomment to enable)
- Disko Btrfs layout: `@` `@home` `@nix` `@log` `@snapshots` subvolumes
- sops-nix: user password hashes and SSH authorized keys read from encrypted file
- Catppuccin Mocha applied globally across Hyprland, foot, bat, delta, Zed, GTK, Qt
- KVM headless output workaround (`exec-once = "hyprctl output create headless"`)
- Hyprland keybinds, animations, blur/transparency, hyprlock + hypridle
- Fish abbreviations for eza/bat/fd/rg/btop/dust/duf/procs
- MPD + ncmpcpp with PipeWire output and FIFO visualizer
- OBS with PipeWire audio capture and AMD VAAPI encode plugins
- Steam + Proton-GE + GameMode + MangoHud + Gamescope + Heroic + Prism Launcher
- Neovim set as default editor with LazyVim-compatible LSP/formatter packages
- OpenSSH hardened (key-only, no root login)
- Weekly Nix GC, store optimisation, unfree packages allowed
- XDG user dirs and MIME default applications

---

## Secrets setup

> Required before first successful `nixos-rebuild switch`.

### 1. Generate an age key pair

Run this on any machine you have access to (can be your current system,
a LiveUSB shell, or any Linux box):

```sh
mkdir -p ~/.config/sops/age
chmod 700 ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Print the public recipient (starts with `age1...`):

```sh
age-keygen -y ~/.config/sops/age/keys.txt
```

Copy this value — you will need it in the next step and on the target machine.

### 2. Set the recipient in `secrets/.sops.yaml`

```yaml
creation_rules:
  - path_regex: secrets\.yaml$
    age:
      - "age1...your-public-key..."
```

### 3. Generate password hashes

Run once per user and save the output:

```sh
mkpasswd -m yescrypt
```

### 4. Fill in `secrets/secrets.yaml`

Replace the placeholder values with real ones:

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

Add one authorized key per line in the `ellen-authorized-keys` block for multiple keys.

### 5. Encrypt the file

```sh
sops -e -i secrets/secrets.yaml
```

The file is now safe to commit. Verify it looks encrypted (will contain a `sops:` metadata block).

### 6. On the target machine post-install

Copy your private age key to the new machine:

```sh
# From another machine via SSH (after first boot):
scp ~/.config/sops/age/keys.txt ellen@<ip>:~/.config/sops/age/keys.txt
```

Or copy it manually from USB. The path must match `sops.age.keyFile` in `hosts/desktop/default.nix`:
`/home/ellen/.config/sops/age/keys.txt`

---

## Fresh install guide

### What you need

- A USB drive (4GB+)
- NixOS minimal ISO: <https://nixos.org/download/>
- This repository available (USB, network share, or cloned after booting)
- The age private key file (see Secrets setup above)

---

### Step 1 — Create a bootable USB

**On Linux:**
```sh
# Replace /dev/sdX with your USB device (check with lsblk first)
dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

**On Windows:** Use [Rufus](https://rufus.ie) in DD mode, or [Balena Etcher](https://etcher.balena.io).

---

### Step 2 — Boot and prepare

1. Enter BIOS/UEFI and:
   - Disable **Secure Boot**
   - Set boot order to USB first
2. Boot from the NixOS USB
3. The minimal ISO drops you to a root shell

---

### Step 3 — Connect to the internet

**Ethernet** (recommended): should connect automatically.

**WiFi:**
```sh
iwctl
# Inside iwctl:
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "YourSSID"
exit
```

Verify:
```sh
ping -c 3 nixos.org
```

---

### Step 4 — Verify the disk device

```sh
lsblk -d -o NAME,SIZE,MODEL
```

Confirm the 1TB NVMe shows up as `nvme0n1` (it almost certainly will on a single-drive system).
If it differs, update `device` in `hosts/desktop/hardware.nix` before continuing.

---

### Step 5 — Get the configuration onto the installer

**Option A — Clone over the network (requires git on the ISO):**
```sh
nix-shell -p git
git clone https://github.com/Shoumeiki/nix-systems /mnt/etc/nixos
```

The configuration should end up at `/mnt/etc/nixos/nix-systems` (or wherever you prefer).

---

### Step 6 — Partition and format with Disko

```sh
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko \
  /mnt/etc/nixos/nix-systems/hosts/desktop/hardware.nix
```

This partitions `/dev/nvme0n1`, formats the ESP as FAT32, and creates the Btrfs
partition with all five subvolumes (`@`, `@home`, `@nix`, `@log`, `@snapshots`),
then mounts everything under `/mnt`.

---

### Step 7 — Generate hardware config and merge

```sh
nixos-generate-config --root /mnt --show-hardware-config
```

Review the output. Copy any entries that are **not** already covered by `hardware.nix`
(PCI IDs, kernel modules for your specific board, initrd modules) into
`hosts/desktop/hardware.nix`. Disko handles the `fileSystems` and `swapDevices`
blocks, so you do not need those from the generated config.

Key things to look for and copy across if present:
- `boot.initrd.availableKernelModules`
- `boot.kernelModules`
- Any `hardware.*` options specific to your motherboard

---

### Step 8 — Place secrets on the installer

Copy your encrypted `secrets/secrets.yaml` (already committed) and your **private** age key:

```sh
# Create the secrets directory on the live system so sops-nix can read it at build time
install -d -m 700 /mnt/home/ellen/.config/sops/age
# Copy your age private key (from USB or another machine via SSH)
cp /path/to/keys.txt /mnt/home/ellen/.config/sops/age/keys.txt
chmod 600 /mnt/home/ellen/.config/sops/age/keys.txt
```

---

### Step 9 — Install

```sh
nixos-install --flake /mnt/etc/nixos/nix-systems#desktop --root /mnt \
  --option extra-substituters 'https://nyx-cache.chaotic.cx/' \
  --option extra-trusted-public-keys 'nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk='
```

The two `--option` flags add the Chaotic Nyx binary cache for the duration of the
install command so the CachyOS kernel is fetched from cache rather than compiled
from source. Without them the install would attempt a multi-hour kernel build.

NixOS will:
1. Pull all flake inputs from the internet
2. Build the full system closure
3. Install it under `/mnt`
4. Prompt you to set a **root** password (set one; you can disable root login after)

This step takes a while (20–60 minutes depending on connection speed).

---

### Step 10 — Reboot

```sh
reboot
```

Remove the USB when prompted. The system should boot to the SDDM login screen.

---

### Step 11 — First-login checklist

- [ ] Log in as `ellen`
- [ ] Verify monitor connectors match `hyprland.nix` — run `hyprctl monitors` and adjust if needed
- [ ] Place a wallpaper at `~/Pictures/wallpaper.jpg` (or update `hyprland.nix`)
- [ ] Bootstrap LazyVim:
  ```sh
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  nvim  # LazyVim installs plugins on first launch
  ```
- [ ] Set your real name and email in `modules/home/git.nix`, then rebuild
- [ ] Authenticate GitHub CLI:
  ```sh
  gh auth login
  ```
- [ ] Update Forgejo credential helper in `modules/home/git.nix`
- [ ] Verify audio: `pactl info | grep Server`
- [ ] Run `hyprctl output create headless` manually if the KVM workaround did not fire
  ```

---

## Rebuilding after changes

```sh
# From inside the repo
sudo nixos-rebuild switch --flake .#desktop

# Check before switching (dry-run build)
sudo nixos-rebuild dry-activate --flake .#desktop

# Update all flake inputs
nix flake update

# Garbage collect old generations
sudo nix-collect-garbage -d
```
