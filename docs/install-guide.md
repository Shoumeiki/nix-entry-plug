# unit-01 install guide

End-to-end procedure for installing `nix-entry-plug` on `unit-01` from a NixOS minimal ISO. Assumes you're bombing the existing OS (no coexistence, no data preservation).

If a rebuild on an already-installed system breaks, see [`recovery.md`](./recovery.md) instead.

---

## 0. Before you start

- [ ] Anything you wanted from the old install is already backed up.
- [ ] Phase 5 closure build has been validated on a machine with disk for it (the deferred Phase 5 gate in [`nix-entry-plug-checklist.md`](./nix-entry-plug-checklist.md)).
- [ ] SSH key is generated and added to GitHub (the repo is public, but you'll want push access from `unit-01` afterwards).
- [ ] `hosts/unit-01/default.nix` has `nerv.disk.device` pointing at the correct disk path. Currently `/dev/nvme0n1` — the single NVMe in unit-01.

> **About `/dev/nvme0n1` vs `/dev/disk/by-id/nvme-…`**
> `/dev/nvme0n1` works because unit-01 has exactly one NVMe drive, so the enumeration is unambiguous. If you ever add a second NVMe, switch `nerv.disk.device` to a `by-id` path so the disko target can't get mistakenly applied to the wrong disk. For the initial install on a single-NVMe system, `nvme0n1` is fine.

---

## 1. Prepare install media

On a working machine:

1. Download the latest **NixOS minimal ISO** (x86_64) from <https://nixos.org/download/#nixos-iso>.
2. Write it to a USB stick (≥ 2 GB):
   ```sh
   sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress conv=fsync
   ```
   Replace `sdX` with the USB device (verify with `lsblk`!).

---

## 2. Boot the installer

1. Plug the USB into unit-01.
2. Boot, hit the firmware boot-menu key (usually F12 / F11 / Del — depends on board).
3. Pick the USB. You should land in a TTY as `nixos`.

---

## 3. Network

Ethernet should just work. If you're on Wi-Fi:

```sh
sudo systemctl start wpa_supplicant
nmtui   # if NetworkManager is up, easier
```

Verify:

```sh
ping -c 3 1.1.1.1
```

---

## 4. Make the installer comfortable to drive remotely (optional but recommended)

The installer user (`nixos`) starts with no password and `sshd` enabled. Setting a password lets you `ssh nixos@<unit-01-ip>` from a second machine and paste commands without retyping.

```sh
passwd                  # set a throwaway password for `nixos`
ip addr                 # find unit-01's address
```

From your laptop:

```sh
ssh nixos@<unit-01-ip>
```

The rest of this guide assumes either path.

---

## 5. Enable flakes for the installer

The minimal ISO doesn't ship flakes enabled.

```sh
sudo mkdir -p /etc/nix
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

---

## 6. Clone the repo

```sh
cd /tmp
git clone https://github.com/Shoumeiki/nix-entry-plug.git
cd nix-entry-plug
```

---

## 7. Partition with disko

> ⚠️ **Destructive.** This wipes `/dev/nvme0n1` entirely. Triple-check the device path matches what you intend.

```sh
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko -- \
  --mode disko \
  --flake .#unit-01
```

When this returns, the layout from `hosts/unit-01/disko.nix` is on disk and everything is mounted under `/mnt`:

```
/mnt           → BTRFS @
/mnt/home      → BTRFS @home
/mnt/nix       → BTRFS @nix
/mnt/var/log   → BTRFS @log
/mnt/.snapshots → BTRFS @snapshots
/mnt/persist   → BTRFS @persist   (Phase 8/Impermanence)
/mnt/boot      → ESP (vfat)
```

Sanity check:

```sh
lsblk
findmnt -R /mnt
```

---

## 8. Install

```sh
sudo nixos-install --flake .#unit-01 --no-root-passwd
```

- `--no-root-passwd` skips the interactive root password prompt. We never log in as root, and `ellen` already gets `wheel` via the flake. If you'd rather set a root password too, drop the flag.
- This will build the full system closure on the real NVMe. Expect a long download (~20 GB from cache.nixos.org for this config) on first install.
- If it fails, fix the cause, then re-run the same command — `nixos-install` is idempotent.

When it finishes successfully you'll see something like `installation finished!`.

---

## 9. First boot

```sh
sudo reboot
```

Pull the USB. You should land at the **Limine** boot menu, then **ReGreet**.

- Username: `ellen`
- Password: whatever the hash in `modules/core/users.nix` decodes to (the one you set yourself in Phase 2 via `mkpasswd -m sha-512`). Phase 7 replaces this with a sops-managed file.

---

## 10. Post-install

Work through the **Post-install boot validation** and **Post-install desktop validation** checklists in [`nix-entry-plug-checklist.md`](./nix-entry-plug-checklist.md) (Phase 6). Each item is a specific thing to confirm now that you're on real hardware — bootloader, monitors, audio, gaming, hibernation, etc.

Once those are green:

1. Open a terminal.
2. `cd ~ && git clone git@github.com:Shoumeiki/nix-entry-plug.git` (or move the existing checkout into your home).
3. From there on, the workflow is `just switch` to apply changes, `just check` before commits, `just gc` periodically.
